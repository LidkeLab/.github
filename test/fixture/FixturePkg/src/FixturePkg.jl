"""
    FixturePkg

The self-test fixture for the lab's shared Julia CI workflow.
"""
module FixturePkg

using LinearAlgebra: norm

export unitize

"""
    unitize(v)

Return `v` scaled to unit length. Throws `ArgumentError` for a zero vector.
"""
function unitize(v::AbstractVector{<:Real})
    n = norm(v)
    iszero(n) && throw(ArgumentError("cannot unitize a zero vector"))
    return v ./ n
end

end
