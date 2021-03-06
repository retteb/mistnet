#' Prior distributions
#' 
#' Prior distributions regularize the model's weights during training
#' 
#' @export
#' @exportClass prior
prior = setRefClass(
  Class = "prior",
  fields = list(),
  methods = list(
    getLogGrad = function(x) stop({"log gradient not defined for this prior"}),
    sample = function(n){stop("sampler not defined for this prior")},
    update = function(){stop("update not defined for this prior")}
  )
)

# gaussian.prior$sd can be a numeric matrix OR a numeric vector
setClassUnion("any.numeric", c("numeric", "matrix"))

#' @export gaussian.prior
#' @exportClass gaussian.prior
gaussian.prior = setRefClass(
  Class = "gaussian.prior",
  fields = list(
    mean = "numeric",
    sd = "any.numeric"
  ),
  contains = "prior",
  methods = list(
    getLogGrad = function(x){
      - (x - .self$mean) / .self$sd^2
    },
    sample = function(n){
      rnorm(n, mean = mean, sd = sd)
    },
    update = function(weights, update.mean, update.sd, min.sd){
      if(update.mean){
        mean <<- rowMeans(weights)
      }
      if(update.sd){
        var.vector = apply(weights, 1, var)
        var.vector = pmax(
          (var.vector + mean(var.vector)) / 2,
          min.sd^2
        )
        sd <<- replicate(ncol(weights), sqrt(var.vector))
      }
    }
  )
)

#' @export laplace.prior
#' @exportClass laplace.prior
laplace.prior = setRefClass(
  Class = "laplace.prior",
  fields = list(
    location = "numeric",
    scale = "numeric"
  ),
  contains = "prior",
  methods = list(
    getLogGrad = function(x){
      # This will work if the learning rate is small. Otherwise, it could 
      # overshoot past zero. That's probably not a big deal in practice?
      - sign(x - location) / scale
    },
    sample = function(n){
      rexp(n, rate  = 1 / scale) * sample(c(-1, 1), size = n, replace = TRUE)
    }
  )
) 



#' @export gp.prior
#' @exportClass gp.prior
gp.prior = setRefClass(
  Class = "gp.prior",
  fields = list(
    means = "matrix",
    K = "array",
    L = "array",
    v = "array",
    inverse.var = "matrix",
    process_noise = "numeric"
  ),
  contains = "prior",
  methods = list(
    initialize = function(){
      
    },
    getLogGrad = function(x){
      # L <<- t(chol(K + diag(nrow(dists)) * process_noise^2))
      # v <<- solve(L, K)
      # inverse.var <<- solve(K - t(v) %*% v)
      
      
      sapply(
        1:nrow(x),
        function(i){
          - inverse.var %*% (x[i, ] - means[i, ])
        }
      )
      
      
    },
    updateMeans = function(coefs){
      # Each row of coefficients has its own posterior mean
      if(length(means) == 0){
        means <<- matrix(NA, nrow = nrow(coefs), ncol = ncol(coefs))
      }
      for(i in 1:nrow(coefs)){
        y = coefs[i, ]
        centered.y = y - mean(y)
        alpha = solve(t(L[i, , ]), solve(L[i, , ], centered.y))
        means[i, ] <<- t(K[i, , ]) %*% alpha + mean(y)
      }
    }
  )
)
