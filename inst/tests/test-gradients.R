context("Gradients")

test_that("sigmoidGrad is accurate", {
  expect_equal(sigmoidGrad(x = 0), 1/4)
  expect_equal(sigmoidGrad(x = Inf), 0)
  expect_equal(sigmoidGrad(x = -Inf), 0)
  
  x = matrix(seq(-10, 10, length = 1E3), ncol = 2)
  
  nl = new("sigmoid.nonlinearity")
  
  expect_equal(
    nl$f(x + 1E-6) - nl$f(x - 1E-6), 
    nl$grad(x) * 2E-6
  )
})


test_that("rectifyGrad is accurate", {
  x = matrix(seq(-10, 10, length = 1E3), ncol = 2)
  expect_true(
    all(rectifyGrad(x) == (x > 0))
  )
  nl = new("rectify.nonlinearity")
  
  expect_equal(
    nl$f(x + 1E-6) - nl$f(x - 1E-6), 
    nl$grad(x = x) * 2E-6
  )
})

test_that("linearGrad is accurate", {
  x = matrix(1:1000, nrow = 10)
  nl = new("linear.nonlinearity")
  
  expect_equal(
    nl$f(x + 1E-6) - nl$f(x - 1E-6), 
    nl$grad(x) * 2E-6
  )
  expect_true(all(nl$grad(x) == 1))
})


test_that("expGrad is accurate", {
  x = matrix(seq(-10, 10, length = 1E3), ncol = 2)
  nl = new("exp.nonlinearity")
  
  expect_equal(
    nl$f(x + 1E-6) - nl$f(x - 1E-6), 
    nl$grad(x) * 2E-6
  )
})


test_that("crossEntropyGrad is accurate", {
  eps = 1E-5
  x = seq(.1, .9, by = .1)
  y = crossEntropy(y = 1, yhat = x)
  y.plus  = crossEntropy(y = 1, yhat = x + eps)
  y.minus = crossEntropy(y = 1, yhat = x - eps)
  grad = crossEntropyGrad(y = 1, yhat = x)
  
  expect_equal(
    (y.plus - y.minus)/2 / eps,
    grad
  )
  
  # Make sure it's symmetrical
  expect_equal(
    (y.plus - y.minus)/2 / eps,
    -rev(crossEntropyGrad(y = 0, yhat = x))
  )
})


test_that("poissonLossGrad is accurate", {
  eps = 1E-5
  x = seq(.1, 10, by = .1)
  y = poissonLoss()$loss(y = 1, yhat = x)
  y.plus  = poissonLoss()$loss(y = 1, yhat = x + eps)
  y.minus = poissonLoss()$loss(y = 1, yhat = x - eps)
  grad = poissonLoss()$grad(y = 1, yhat = x)
  
  expect_equal(
    (y.plus - y.minus)/2 / eps,
    grad
  )
})


test_that("squaredLossGrad is accurate", {
  eps = 1E-5
  x = seq(-10, 10, by = .1)
  y = squaredLoss()$loss(y = 1, yhat = x)
  y.plus  = squaredLoss()$loss(y = 1, yhat = x + eps)
  y.minus = squaredLoss()$loss(y = 1, yhat = x - eps)
  grad = squaredLoss()$grad(y = 1, yhat = x)
  
  expect_equal(
    (y.plus - y.minus)/2 / eps,
    grad
  )
})



test_that("binomialLossGrad is accurate", {
  eps = 1E-5
  x = seq(0, 1, by = .1)
  n = 17L
  y = binomialLoss(n = n)$loss(y = 1, yhat = x)
  expect_warning(
    {
      y.plus  = binomialLoss(n = n)$loss(y = 1, yhat = x + eps)
      y.minus = binomialLoss(n = n)$loss(y = 1, yhat = x - eps)
    },
    "NaN"
  )
  grad = binomialLoss(n = n)$grad(y = 1, yhat = x, n = n)
  
  finite.elements = is.finite(y)
  
  expect_equal(
    (y.plus - y.minus)[finite.elements] / 2 / eps,
    grad[finite.elements]
  )
  
  # Ensure that zero and one are the non-finite elements of y
  expect_equal(
    finite.elements,
    !(x %in% c(0, 1))
  )
})



eps = 1E-7
n = 37
n.out = 17
n.hid = 13
y = matrix(rbinom(n * n.out, size = 1, prob = .5), ncol = n.out)

test_that("output layer gradient is accurate", {
  
  # activation
  a = matrix(rnorm(n * n.out), nrow = n)
  
  # output
  o = sigmoid(a)
  o.plus = sigmoid(a + eps)
  o.minus = sigmoid(a - eps)
  
  error = crossEntropy(y = y, yhat = o)
  error.plus = crossEntropy(y = y, yhat = o.plus)
  error.minus = crossEntropy(y = y, yhat = o.minus)
  
  error.grad = .5 / eps * (error.plus - error.minus)
  
  expect_equal(
    crossEntropyGrad(y = y, yhat = o) * sigmoidGrad(x = a),
    error.grad
  )
})


# This test has largely been duplicated in test-backprop.R and should probably
# be removed.  It's not hurting anything right now, though...
test_that("backprop works",{
  h = matrix(rnorm(n * n.hid), nrow = n) / 10
  b2 = rnorm(n.out)
  
  w2 = w2.plus = w2.minus = matrix(rnorm(n.hid * n.out), nrow = n.hid)
  
  target.hidden = sample.int(n.hid, 1)
  
  w2.plus[target.hidden , ]  = w2[target.hidden , ] + eps / 2
  w2.minus[target.hidden , ] = w2[target.hidden , ] - eps / 2
  
  a = h %*% w2 %plus% b2
  o = sigmoid(a)
  o.plus =  sigmoid(h %*% w2.plus %plus% b2)
  o.minus = sigmoid(h %*% w2.minus %plus% b2)
  
  error = crossEntropy(y = y, yhat = o)
  error.plus = crossEntropy(y = y, yhat = o.plus)
  error.minus = crossEntropy(y = y, yhat = o.minus)
  
  observed.grad = sapply(
    1:n, 
    function(i){
      (error.plus - error.minus)[i, ] / eps
    }
  )
  predicted.grad = -sapply(
    1:n, function(i){
      -crossEntropyGrad(y = y, yhat = o)[i, ] * 
        sigmoidGrad(x = a)[i, ] * 
        h[i, target.hidden] 
    }
  )
  
  expect_equal(observed.grad, predicted.grad, tolerance = eps)
  
  delta = crossEntropyGrad(y = y, yhat = o) * sigmoidGrad(x = a)
  
  x = matrixMultiplyGrad(
    n_out = n.out,
    error_grad = delta,
    input_act = h
  )
  
  expect_equal(x[target.hidden, ], rowSums(observed.grad), tolerance = eps)
})
