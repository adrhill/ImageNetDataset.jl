#===========#
# Interface #
#===========#

"""
    AbstractTransform

Abstract type of ImageNet Preprocessing pipelines.
Expected interface:

- `transform(method, image_path)`: load image and convert it to a WHC array
- `inverse_transform(method, array)`: convert WHC[N] array to image[s]
"""
abstract type AbstractTransform end

(tfm::AbstractTransform)(path::AbstractString) = transform(tfm, path)

"""
    transform(tfm, path)

Load image from path and convert it to a WHC array using preprocessing transformation `tfm`.
"""
function transform end

"""
    inverse_transform(tfm, path)

Convert WHC array to an image by applying the inverse of the preprocessing transformation `tfm`.
"""
function inverse_transform end

#===========#
# Utilities #
#===========#

# Coefficients taken from PyTorch's ImageNet normalization code
const PYTORCH_MEAN = (0.485f0, 0.456f0, 0.406f0)
const PYTORCH_STD = (0.229f0, 0.224f0, 0.225f0)
const OUTPUT_SIZE = (224, 224)

normalize(x, μ, σ) = (x .- μ) ./ σ
inverse_normalize(x, μ, σ) = x .* σ .+ μ

function normalize!(x, μ, σ)
    @. x = (x - μ) / σ
    return x
end
function inverse_normalize!(x, μ, σ)
    @. x = x * σ + μ
    return x
end

# Load image from file path
function load_image(path::AbstractString, output_size, T::Type=Float32)
    JpegTurbo.jpeg_decode(RGB{T}, path; preferred_size=output_size)
end

# Take rectangle of pixels of shape `output_size` at the center of image `im`
function center_crop(im::AbstractMatrix, output_size)
    h2, w2 = div.(output_size, 2) # half height, half width of view
    h_adjust, w_adjust = adjust_index.(output_size)
    return @view im[
        ((div(end, 2) - h2):(div(end, 2) + h2 - h_adjust)) .+ 1,
        ((div(end, 2) - w2):(div(end, 2) + w2 - w_adjust)) .+ 1,
    ]
end
adjust_index(i::Integer) = ifelse(iszero(i % 2), 1, 0)

#=====================#
# CenterCropNormalize #
#=====================#

"""
    CenterCropNormalize([; size, mean, std])

Preprocessing pipeline that center-crops an input image to `size` and normalizes it
according to `mean` and `std`.

Applied using `transform` and `inverse_transform`.

## Keyword arguments:
- `size`: Output size of the center-crop. Defaults to $OUTPUT_SIZE.
- `mean`: Mean of the normalization over color channels. Defaults to $PYTORCH_MEAN.
- `std`: Standard deviation of the normalization over color channels Defaults to $PYTORCH_STD.

"""
Base.@kwdef struct CenterCropNormalize{T} <: AbstractTransform
    size::NTuple{2,Int} = OUTPUT_SIZE
    mean::NTuple{3,T} = PYTORCH_MEAN
    std::NTuple{3,T} = PYTORCH_STD
end

function transform(tfm::CenterCropNormalize{T}, path::AbstractString) where {T}
    im = load_image(path, tfm.size, T)
    im = center_crop(im, tfm.size)
    im = normalize!(channelview(im), tfm.mean, tfm.std)
    return PermutedDimsArray(im, (3, 2, 1)) # Convert from Image.jl's CHW to Flux's WHC
end

function inverse_transform(tfm::CenterCropNormalize, x::AbstractArray{T,N}) where {T,N}
    @assert N == 3 || N == 4
    x = PermutedDimsArray(x, (3, 2, 1, 4:N...)) # Convert from WHC[N] to CHW[N]
    return colorview(RGB, inverse_normalize(x, tfm.mean, tfm.std))
end
