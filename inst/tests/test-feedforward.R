context("Feedforward")

test_that("Single-layer feedforward works", {
  n.minibatch = 5L
  
  l = createLayer(
    n.inputs = 4L,
    n.outputs = 7L,
    n.minibatch = n.minibatch,
    n.importance.samples = 3L,
    nonlinearity = sigmoid.nonlinearity(),
    prior = gaussian.prior(mean = 0, sd = 1),
    updater = sgd.updater(momentum = .9, learning.rate = .001)
  )
  l.copy = l$copy()
  
  input.matrix = matrix(rnorm(20), ncol = 4)
  expect_error(l$forwardPass(input.matrix), "sample.num is missing")
  
  l$forwardPass(input.matrix, 2L)
  
  
  expect_equal(
    l$inputs[ , , 2],
    (input.matrix %*% l$weights) %plus% l$biases
  )
  expect_equal(
    l$outputs[ , , 2],
    l$nonlinearity$f((input.matrix %*% l$weights) %plus% l$biases)
  )
  
  # Nothing should change during feedforward except the listed fields
  for(name in layer$fields()){
    name.shouldnt.change = name %in% c("activations", "outputs")
    if(name.shouldnt.change){
    }else{
      expect_equal(l[[name]], l.copy[[name]])
    }
  }
})


test_that("Multi-layer feedforward works", {
  n.minibatch = 5L
  
  y = matrix(plogis(rnorm(100)), nrow = 20, ncol = 5)
  net = mistnet(
    x = matrix(rnorm(100), nrow = 20, ncol = 5),
    y = y,
    layer.definitions = list(
      defineLayer(
        nonlinearity = rectify.nonlinearity(), 
        size = 23, 
        prior = gaussian.prior(mean = 0, sd =  0.001)
      ),
      defineLayer(
        nonlinearity = rectify.nonlinearity(), 
        size = 31, 
        prior = gaussian.prior(mean = 0, sd =  0.001)
      ),
      defineLayer(
        nonlinearity = sigmoid.nonlinearity(), 
        size = ncol(y), 
        prior = gaussian.prior(mean = 0, sd =  0.001)
      )
    ),
    loss = bernoulliLoss(),
    n.importance.samples = 27L,
    n.minibatch = n.minibatch,
    sampler = gaussian.sampler(ncol = 3L, sd = 1),
    training.iterations = 0L,
    updater = adagrad.updater(learning.rate = .01),
    initialize.weights = FALSE,
    initialize.biases = FALSE
  )
  
  ranefs = net$sampler$sample(nrow = net$row.selector$n.minibatch)
  net$selectMinibatch()
  net$feedForward(
    cbind(
      net$x[net$row.selector$minibatch.ids, ], 
      ranefs
    ),
    2
  )
  
  expect_equal(
    net$layers[[1]]$nonlinearity$f(
      (cbind(ranefs, net$x[net$row.selector$minibatch.ids, ]) %*% net$layers[[1]]$weights) %plus% net$layers[[1]]$biases
    ),
    net$layers[[1]]$outputs[,,2]
  )
  
  expect_equal(
    net$layers[[2]]$nonlinearity$f(
      (net$layers[[1]]$outputs[,,2] %*% net$layers[[2]]$weights) %plus% net$layers[[2]]$biases
    ),
    net$layers[[2]]$outputs[,,2]
  )
  
  
  expect_equal(
    net$layers[[3]]$nonlinearity$f(
      (net$layers[[2]]$outputs[,,2] %*% net$layers[[3]]$weights) %plus% net$layers[[3]]$biases
    ),
    net$layers[[3]]$outputs[,,2]
  )
})

