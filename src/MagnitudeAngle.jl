module MagnitudeAngle
import Unitful
import Unitful: NoDims, °, uconvert
export MagAngle

const Mag = Union{Real} #, LogLevels.dB
const Angle = Union{Real, Unitful.Quantity{<:Real, typeof(NoDims), typeof(°)}}

struct MagAngle{T<:Real} <: Number
    z::Complex{T}
    function MagAngle{T}(z::Complex) where {T}
        return new{T}(convert(Complex{T}, z))
    end
    function MagAngle{T}(mag::Mag, angle::Angle) where {T}
        signbit(mag) && throw(ArgumentError("magnitude must be positive."))
        return new{T}(Complex{T}(convert(T, mag*cos(angle)), convert(T, mag*sin(angle))))
    end
    function MagAngle{T}(mag::Mag) where {T}
        signbit(mag) && throw(ArgumentError("magnitude must be positive."))
        return new{T}(Complex{T}(convert(T, mag), zero(T)))
    end
end
MagAngle(z::Complex{T}) where {T} = MagAngle{float(T)}(z)
MagAngle(m::Mag, a::Angle) = MagAngle{typeof(float(m))}(m,a)
MagAngle(m::Mag) = MagAngle(m,0)

Base.convert(::Type{MagAngle{S}}, z::MagAngle{S}) where {S} = z
Base.convert(::Type{MagAngle{S}}, z::MagAngle) where {S} = MagAngle{S}(z.z)
Base.convert(::Type{MagAngle{S}}, z::Complex) where {S} = MagAngle{S}(z)
Base.convert(::Type{MagAngle{S}}, x::Number) where {S} = MagAngle{S}(x,0)
Base.convert(::Type{Complex{T}}, z::MagAngle{T}) where {T} = z.z
Base.convert(::Type{Complex{T}}, z::MagAngle) where {T} = convert(Complex{T}, z.z)
Base.convert(::Type{T}, z::MagAngle) where {T<:Real} =
    isreal(z.z) ? convert(T, real(z.z)) : throw(InexactError())

Base.convert(::Type{MagAngle}, z::MagAngle) = z
Base.convert(::Type{MagAngle}, z::Complex) = MagAngle(z)
Base.convert(::Type{MagAngle}, x::Real) = MagAngle(x,0)

Base.promote_rule(::Type{MagAngle{A}}, ::Type{MagAngle{B}}) where {A,B} =
    MagAngle{promote_type(A,B)}
Base.promote_rule(::Type{MagAngle{A}}, ::Type{Complex{B}}) where {A,B} =
    Complex{promote_type(A,B)}
Base.promote_rule(::Type{MagAngle{A}}, ::Type{B}) where {B<:Mag,A} =
    MagAngle{promote_type(A,B)}

Base.real(z::MagAngle) = real(z.z)
Base.imag(z::MagAngle) = imag(z.z)

Base.isreal(z::MagAngle) = iszero(imag(z))
Base.isinteger(z::MagAngle) = isreal(z) & isinteger(real(z))
Base.isfinite(z::MagAngle) = isfinite(real(z)) & isfinite(imag(z))
Base.isnan(z::MagAngle) = isnan(real(z)) | isnan(imag(z))
Base.isinf(z::MagAngle) = isinf(real(z)) | isinf(imag(z))
Base.iszero(z::MagAngle) = iszero(real(z)) & iszero(imag(z))
Base.flipsign(x::MagAngle, y::Real) = ifelse(signbit(y), -x, x)

function Base.show(io::IO, z::MagAngle)
    m, a = abs(z), angle(z)
    compact = get(io, :compact, false)
    show(io, m)
    print(io, compact ? "; ∠" : " * exp(im * ")
    show(io, a)
    print(io, compact ? "" : ")")
end

Base. ==(z::MagAngle, w::MagAngle) = (real(z) == real(w)) & (imag(z) == imag(w))
Base. ==(z::MagAngle, x::Mag) = isreal(z) && real(z) == x
Base. ==(x::Mag, z::MagAngle) = isreal(z) && real(z) == x
Base. ==(z::MagAngle, w::Complex) = (real(z) == real(w)) & (imag(z) == imag(w))
Base. ==(z::Complex, w::MagAngle) = (real(z) == real(w)) & (imag(z) == imag(w))

Base.isequal(z::MagAngle, w::MagAngle) = isequal(abs(z),abs(w)) & isequal(angle(z),angle(w))

Base.conj(z::MagAngle) = MagAngle(conj(z.z))
Base.abs(z::MagAngle) = abs(z.z)
Base.angle(z::MagAngle) = uconvert(°, angle(z.z))
Base.abs2(z::MagAngle) = abs(z)*abs(z)
Base.inv(z::MagAngle)  = MagAngle(inv(z.z))

Base. -(z::MagAngle) = MagAngle(-z.z)
Base. +(z::MagAngle, w::MagAngle) = MagAngle(z.z+w.z)
Base. -(z::MagAngle, w::MagAngle) = MagAngle(z.z-w.z)
Base. *(z::MagAngle, w::MagAngle) = MagAngle(z.z*w.z)

# muladd...
# Bool stuff...

# adding or multiplying real & complex is common
Base. +(x::Real, z::MagAngle) = MagAngle(x + z.z)
Base. +(z::MagAngle, x::Real) = MagAngle(x + z.z)
Base. -(x::Real, z::MagAngle) = MagAngle(x - z.z)
Base. -(z::MagAngle, x::Real) = MagAngle(z.z - x)
Base. *(x::Real, z::MagAngle) = MagAngle(x * z.z)
Base. *(z::MagAngle, x::Real) = MagAngle(x * z.z)

Base. sqrt(z::MagAngle) = MagAngle(sqrt(z.z))

# more muladd stuff...

Base. /(a::Real, z::MagAngle) = MagAngle(a / z.z)
Base. /(z::MagAngle, a::Real) = MagAngle(z.z / a)
Base. /(a::MagAngle, b::MagAngle) = MagAngle(a.z / b.z)

end # module
