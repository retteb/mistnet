network = setRefClass(
  Class = "network",
  fields = list(
    x = "matrix",
    y = "matrix",
    layers = "list",
    n.layers = "integer",
    minibatch.size = "integer",
    minibatch.ids = "integer",
    loss = "function",
    lossGradient = "function"
  ),
  methods = list(
    newMinibatch = function(row.nums){
      if(missing(row.nums)){
        minibatch.ids <<- sample.int(minibatch.size, replace = FALSE)
      }else{
        # Should this check that length(row.nums) == minibatch.size?
        minibatch.ids <<- row.nums
      }
    },
    feedForward = function(){
      # First layer gets its inputs from x
      layers[[1]]$forwardPass(x[minibatch.ids, ])
      
      # Subsequent layers get their inputs from previous layers
      for(i in 2:n.layers){
        layers[[i]]$forwardPass(layers[[i - 1]]$output)
      }
    },
    backprop = function(){
      
      # Final layer just sees error from the loss gradient
      layers[[n.layers]]$backwardPass(
        lossGradient(y = y[minibatch.ids, ], yhat = layers[[n.layers]]$output)
      )
      
      # Earlier layers' error gradients are filtered through the coefficients of
      # the layer above.
      for(i in (n.layers - 1):1){
        layers[[i]]$backwardPass(
          tcrossprod(
            layers[[i + 1]]$error.grad, 
            layers[[i + 1]]$coefficients
          )
        )
      }
    },
    updateCoefficients = function(){
      for(layer in layers){
        layer$updateCoefficients()
      }
    },
    predict = function(newdata){
      feedForward(newdata)
      return(output)
    },
    fit = function(iterations){
      for(i in 1:iterations){
        newMinibatch()
        feedForward()
        backprop()
        updateCoefficients()
      }
    }
  )
)