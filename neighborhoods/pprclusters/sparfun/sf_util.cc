/**
 * @file sf_util.cc
 * Sparse matrix utility routines
 */

/*
 * David F. Gleich
 * Copyright, Microsoft Corporation, 2008
 */

/** History
 * 2008-09-01: Initial coding
 */

#include "sparfun_util.h"

#ifdef __APPLE__
#include <tr1/random>
#else
#include <random>
#endif

#if defined(_WIN32) || defined(_WIN64) || defined(__APPLE__)
#define tr1ns std::tr1
#else
#define tr1ns std
#endif

#pragma warning(disable:4996)

#include <sys/types.h>
#include <sys/timeb.h>
double sf_time()
{
#if defined(_WIN32) || defined(_WIN64)
  struct __timeb64 t; _ftime64(&t);
  return (t.time*1.0 + t.millitm/1000.0);
#else
  struct timeval t; gettimeofday(&t, 0);
  return (t.tv_sec*1.0 + t.tv_usec/1000000.0);
#endif
}

tr1ns::mt19937 sparfun_rand;

typedef tr1ns::mt19937                                        generator_t;
typedef tr1ns::uniform_real<double>                           distribution_t;
typedef tr1ns::variate_generator<generator_t, distribution_t> variate_t;
variate_t sparfun_rand_unif(sparfun_rand, distribution_t(0.0, 1.0));

void sf_srand(unsigned long seed)
{
  sparfun_rand.seed(seed);
  sparfun_rand_unif = variate_t(sparfun_rand, distribution_t(0.0, 1.0));
}

double sf_rand(double min, double max)
{
  tr1ns::uniform_real<double> dist(min,max);
  return dist(sparfun_rand_unif);
}

int sf_randint(int min, int max)
{
  tr1ns::uniform_int<int> dist(min,max);
  return dist(sparfun_rand_unif);
}
