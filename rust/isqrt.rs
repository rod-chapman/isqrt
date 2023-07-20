extern crate creusot_contracts;
use creusot_contracts::*;

#[predicate]
fn isqrt_spec(x : Int, res: Int) -> bool {
  res >= 0 && sqr(res) <= x && x < sqr(res + 1)
}

#[logic]
fn sqr(x : Int) -> Int {
  x * x
}

#[ensures(isqrt_spec(x@, result@))]
fn isqrt(x : u32) -> u32 {
  let mut count : u32 = 0;
  let mut sum : u64 = 1;

  #[invariant(x@ >= sqr(count@))]
  #[invariant(sum@ == sqr(count@ + 1))]
  // #[variant(x - count)]
  while sum <= x as u64 {
    count += 1 ;
    sum += 2 * count as u64 + 1
  }
  count
}