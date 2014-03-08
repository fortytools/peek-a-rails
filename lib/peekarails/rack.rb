require 'rack'
require 'peekarails/metrics'

class Peekarails::Rack

  attr_reader :app, :options

  def initialize app, options = {}
    @app = app
    @options = options
  end

  def call env
    request = ActionDispatch::Request.new(env)

    if request.filtered_path =~ /^\/assets\/*./
      return app.call(env)
    end

    context = {}
    context[:method] = request.request_method
    context[:path] = request.filtered_path
    context[:timestamp] = Time.now.to_i

    Thread.current[:peekarails_context] = context

    gc_before = GC.stat

    status, headers, body = nil

    begin
      status, headers, body = app.call(env)
    rescue Exception => exception
      context = Thread.current[:peekarails_context]
      context[:error] = true

      Peekarails::Metrics.record_request! context

      raise exception
    end

    gc_after = GC.stat

    context = Thread.current[:peekarails_context]

    context[:status] = status

    context[:gc_count] = gc_after[:count] - gc_before[:count]
    context[:gc_minor_count] = gc_after[:minor_gc_count] - gc_before[:minor_gc_count]
    context[:gc_major_count] = gc_after[:major_gc_count] - gc_before[:major_gc_count]
    context[:gc_heap_used] = gc_after[:heap_used]
    context[:gc_heap_free] = gc_after[:heap_length] - gc_after[:heap_used]

    Peekarails::Metrics.record_request! context

    [status, headers, body]
  end
end
