mistnet = function(
  x,
  y,
  loss.type,
  learning.schedule,
  momentum.schedule,
  minibatch.size = 50,
  nonlinearities,
  hidden.sizes,
  priors
){
  n.layers = length(nonlinearities)
  stopifnot(length(priors) == n.layers, length(hidden.sizes) == (n.layers - 1))
  
  layer.sizes = c(ncol(x), hidden.sizes, ncol(y))
  
  network$new(
    x = x,
    y = y,
    loss = loss.type,
    lossGradient = paste0(loss.type, "Grad"),
    layers = lapply(
      1:n.layers,
      function(i){
        createLayer(
          dim = layer.sizes[i:(i + 1)],
          learning.rate = start.rate,
          momentum = start.momentum,
          prior = priors[[i]],
          dataset.size = nrow(x)
        )
      }
    ),
    n.layers = n.layers
  )
}