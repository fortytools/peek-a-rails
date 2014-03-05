@renderSingleGraph = (name, data, color, type, element) ->
  root = document.querySelector(element)

  graph = new Rickshaw.Graph {
    height: 150,
    element: root.querySelector('.graph'),
    renderer: type,
    interpolation: 'linear',
    series: [
      { data: data, color: color, name: name }
    ]
  } 

  graph.render()

  hoverDetail = new Rickshaw.Graph.HoverDetail {
    graph: graph,
    yFormatter: (y) ->
      y
  }


  xAxis = new Rickshaw.Graph.Axis.Time {
    graph: graph
  }
  xAxis.render()

  yAxis = new Rickshaw.Graph.Axis.Y {
    graph: graph,
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT
  }
  yAxis.render()

  slider = new Rickshaw.Graph.RangeSlider({
    graph: graph,
    element: root.querySelector('.slider')
  })

  return graph

@renderMultiGraph = (datas, element) ->
  palette = new Rickshaw.Color.Palette { scheme: 'colorwheel' }

  root = document.querySelector(element)

  series = datas.map (data) ->
    { data: data.data, color: palette.color(), name: data.name }

  graph = new Rickshaw.Graph {
    height: 150,
    element: root.querySelector('.graph'),
    renderer: 'area',
    interpolation: 'linear',
    series: series
  }

  graph.render()

  hoverDetail = new Rickshaw.Graph.HoverDetail {
    graph: graph,
    yFormatter: (y) ->
      y
  }

  xAxis = new Rickshaw.Graph.Axis.Time {
    graph: graph
  }
  xAxis.render()

  yAxis = new Rickshaw.Graph.Axis.Y {
    graph: graph,
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT
  }
  yAxis.render()

  slider = new Rickshaw.Graph.RangeSlider {
    graph: graph,
    element: root.querySelector('.slider')
  }

  return graph


