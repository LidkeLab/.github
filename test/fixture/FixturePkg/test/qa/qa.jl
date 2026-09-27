# Default QA (admiral decision 0008): Aqua and ExplicitImports, unchanged in every package
# (the package name is read from Project.toml). Aqua and ExplicitImports go in the test env.
using Test, TOML, Aqua, ExplicitImports

const PKGNAME = Symbol(TOML.parsefile(joinpath(@__DIR__, "..", "..", "Project.toml"))["name"])
@eval using $PKGNAME
const PKG = getfield(@__MODULE__, PKGNAME)

@testset "Aqua" begin
    Aqua.test_all(PKG)
    # Opt-out: switch off one check and state the reason beside it, e.g.
    #   Aqua.test_all(PKG; ambiguities=false)  # reason: ambiguities come from ForwardDiff's Dual methods
end

@testset "ExplicitImports" begin
    @test check_no_implicit_imports(PKG) === nothing
    @test check_no_stale_explicit_imports(PKG) === nothing
    # Opt-out: ignore named items and state the reason, e.g.
    #   check_no_implicit_imports(PKG; ignore=(:Foo,))  # reason: Foo is re-exported on purpose
end
