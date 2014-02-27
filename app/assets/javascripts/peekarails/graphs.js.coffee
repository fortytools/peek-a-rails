@renderSingleGraph = (name, data, color, type, element) ->
  graph = new Rickshaw.Graph {
    element: document.querySelector(element),
    renderer: type,
    interpolation: 'linear',
    series: [
      { data: data, color: color, name: name }
    ]
  } 

  hoverDetail = new Rickshaw.Graph.HoverDetail {
    graph: graph,
    yFormatter: (y) ->
      y
  }

  xAxis = new Rickshaw.Graph.Axis.Time {
    graph: graph
  }
  yAxis = new Rickshaw.Graph.Axis.Y {
    graph: graph,
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT
  }

  graph.render()
  xAxis.render()
  yAxis.render()

  return graph

@renderMultiGraph = (datas, element) ->
  palette = new Rickshaw.Color.Palette { scheme: 'colorwheel' }

  root = document.querySelector(element)

  series = datas.map (data) ->
    { data: data.data, color: palette.color(), name: data.name }

  graph = new Rickshaw.Graph {
    element: root.querySelector('.graph'),
    renderer: 'area',
    interpolation: 'linear',
    series: series
  }

  hoverDetail = new Rickshaw.Graph.HoverDetail {
    graph: graph,
    yFormatter: (y) ->
      y
  }

  xAxis = new Rickshaw.Graph.Axis.Time {
    graph: graph
  }
  yAxis = new Rickshaw.Graph.Axis.Y {
    graph: graph,
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT
  }

  slider = new Rickshaw.Graph.RangeSlider {
    graph: graph,
    element: root.querySelector('.slider')
  }

  graph.render()
  slider.render()
  xAxis.render()
  yAxis.render()

  return graph


