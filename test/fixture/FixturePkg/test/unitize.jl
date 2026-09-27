using Test, FixturePkg

@test unitize([3.0, 4.0]) ≈ [0.6, 0.8]
@test unitize([2]) == [1.0]
@test_throws ArgumentError unitize([0.0, 0.0])
