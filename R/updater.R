updater = setRefClass(
  Class = "updater",
  fields = list(
    delta = "matrix"
  ),
  methods = list(
    computeDelta = function(...){
      stop("computeDelta not defined for this updater")
    }
  )
)

sgd.updater = setRefClass(
  Class = "sgd.updater",
  contains = "updater",
  fields = list(
    momentum = "numeric",
    learning.rate = "numeric",
    delta = "matrix"
  ),
  methods = list(
    computeDelta = function(gradient){
      delta <<- delta * momentum - gradient * learning.rate
    }
  )
)


adagrad.updater = setRefClass(
  Class = "adagrad.updater",
  contains = "updater",
  fields = list(
    learning.rate = "numeric",
    squared.grad = "matrix"
  ),
  methods = list(
    computeDelta = function(gradient){
      squared.grad <<- squared.grad + gradient^2
      
      delta <<- learning.rate / sqrt(squared.grad) * gradient
    }
  )
)


# Rho is a decay rate. Controls how long the updater remembers the squared
#    magnitude of previous updates
# Epsilon is a fudge factor that determines initial rates and keeps things from
#    approaching zero.
adadelta.updater = setRefClass(
  Class = "adadelta.updater",
  contains = "updater",
  fields = list(
    rho = "numeric",
    epsilon = "numeric",
    squared.grad = "matrix",
    delta = "matrix",
    squared.delta = "matrix"
  ),
  methods = list(
    RMS = function(x.squared){
      sqrt(x.squared + epsilon)
    },
    computeDelta = function(gradient){
      # Line numbers correspond to Algorithm 1 in Zeiler 2012
      # ADADELTA: AN ADAPTIVE LEARNING RATE METHOD
      # http://www.matthewzeiler.com/pubs/googleTR2012/googleTR2012.pdf
      
      # Line 4: accumulate gradient
      squared.grad <<- rho * squared.grad + (1 - rho) * gradient^2
      
      # Line 5: compute update. RMS(x) is calculated here as 
      #   `sqrt(x + epsilon)` to prevent zero values in the denominator.
      delta <<- -RMS(squared.delta) / RMS(squared.grad) * gradient
      
      # Line 6: accumulate updates
      squared.delta <<- rho * squared.delta + (1 - rho) * delta^2
    }
  )
)