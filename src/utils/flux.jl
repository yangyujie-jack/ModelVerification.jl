using .Flux

# Network -> Flux

activation(x) = GeneralAct(x)

activation(::typeof(identity)) = Id()
activation(::typeof(relu)) = ReLU()

layer(x) = error("Can't use $x as a layer.")

if isdefined(Flux, :Tracker)
    layer(d::Dense) = Layer(Flux.Tracker.data(d.weight), Flux.Tracker.data(d.bias), activation(d.σ))
else
    layer(d::Dense) = Layer(d.weight, d.bias, activation(d.σ))
end

"""
    network(c::Chain)

Converts `Flux.Chain` to a `Network`.
"""
network(c::Chain) = Network([layer.(c.layers)...])

# Flux -> Network

_flux(::ReLU) = relu
_flux(::Id) = identity
_flux(f::GeneralAct) = f.f

_flux(m::Layer) = Dense(m.weights, m.bias, _flux(m.activation))
_flux(m::Network) = Chain(_flux.(m.layers)...)

"""
    Flux.Chain(m::Network)

Converts `Network` to a `Flux.Chain`.
"""
Flux.Chain(m::Network) = _flux(m)
