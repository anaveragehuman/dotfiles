import Pkg

atreplinit() do _
    for pkg in (:BenchmarkTools, :Revise)
        @info "Loading $pkg"
        pkgstr = String(pkg)
        if Base.identify_package(pkgstr) === nothing
            Pkg.add(pkgstr)
        end
        :(using $pkg) |> eval
    end
end
