rover = setClass(
  Class = "rover",
  slots = list(
    output = "matrix",
    x = "matrix",
    y = "matrix",
    longlat = "matrix",
    weights = "list",
    biases = "list",
    activations = "list",
    dropout.masks = "list",
    nrow = "integer"
  ),
  #sealed = TRUE,
  validity = function(object){
    if(!test_nrow(object)) stop("incorrect number of rows")
  }
)

test_nrow = function(object){
  row.objects = c(
    object@activations, 
    list(object@x), 
    list(object@y),
    list(object@longlat)
  )
  
  all(
    sapply(
      row.objects, function(x){
        (nrow(x) == object@nrow) | (nrow(x) == 0)
      }
    )
  )
}
