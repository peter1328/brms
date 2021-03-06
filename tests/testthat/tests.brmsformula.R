test_that("brmsformula validates formulas of non-linear parameters", {
  expect_error(bf(y ~ a, ~ 1, a ~ 1),
               "Additional formulas must be named")
  expect_error(bf(y ~ a^x, a.b ~ 1),
               "not contain dots or underscores")
  expect_error(bf(y ~ a^(x+b), a_b ~ 1),
               "not contain dots or underscores")
})

test_that("brmsformula validates formulas of auxiliary parameters", {
  expect_error(bf(y ~ a, ~ 1, sigma ~ 1),
               "Additional formulas must be named")
  expect_error(bf(y ~ a^x, a ~ 1, family = gaussian()),
               "The parameter 'a' is not a valid distributional")
})

test_that("brmsformula does not change a 'brmsformula' object", {
  form <- bf(y ~ a, sigma ~ 1)
  expect_identical(form, bf(form))
  form <- bf(y ~ a, sigma ~ 1, a ~ x, nl = TRUE)
  expect_identical(form, bf(form))
})

test_that("brmsformula is backwards compatible", {
  expect_warning(form <- bf(y ~ a * exp(-b * x), 
                            nonlinear = a + b ~ 1),
                 "Argument 'nonlinear' is deprecated")
  expect_equivalent(pforms(form), list(a ~ 1, b ~ 1))
  expect_true(attr(form$formula, "nl"))
  
  expect_warning(form <- bf(y ~ a * exp(-b * x), 
                            nonlinear = list(a ~ x, b ~ 1)),
                 "Argument 'nonlinear' is deprecated")
  expect_equivalent(pforms(form), list(a ~ x, b ~ 1))
  expect_true(attr(form$formula, "nl"))
  
  form <- structure(y ~ x + z, sigma = sigma ~ x)
  class(form) <- c("brmsformula", "formula")
  form <- bf(form)
  expect_equal(form$formula, y ~ x + z)
  expect_equal(pforms(form), list(sigma = sigma ~ x))
  expect_true(!attr(form$formula, "nl"))
  
  form <- structure(y ~ a * exp(-b * x),
                    nonlinear = list(a = a ~ x, b = b ~ 1))
  class(form) <- c("brmsformula", "formula")
  form <- bf(form)
  expect_equal(form$formula, y ~ a * exp(-b * x))
  expect_equal(pforms(form), list(a = a ~ x, b = b ~ 1))
  expect_true(attr(form$formula, "nl"))
})

test_that("brmsformula detects auxiliary parameter equations", {
  expect_error(bf(y~x, sigma1 = "sigmaa2"),
               "Can only equate parameters of the same class")
  expect_error(bf(y~x, mu3 = "mu2"),
               "Equating parameters of class 'mu' is not allowed")
  expect_error(bf(y~x, sigma1 = "sigma1"),
               "Equating 'sigma1' with itself is not meaningful")
  expect_error(bf(y~x, shape1 ~ x, shape2 = "shape1"),
               "Cannot use predicted parameters on the right-hand side")
  expect_error(bf(y~x, shape1 = "shape3", shape2 = "shape1"),
               "Cannot use fixed parameters on the right-hand side")
})
