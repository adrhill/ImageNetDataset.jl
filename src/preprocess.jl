# Coefficients taken from PyTorch's ImageNet normalization code
const PYTORCH_MEAN = (0.485f0, 0.456f0, 0.406f0)
const PYTORCH_STD = (0.229f0, 0.224f0, 0.225f0)
const OUTPUT_SIZE = (224, 224)
const OPEN_SIZE = (256, 256)

const DOC_TRANSFORM_OUTPUT = "Returns an array in WHC format `(width, height, channels)`."

const DOC_TRANSFORM_APPLY = "Applied using [`transform`](@ref) and [`inverse_transform`](@ref)."

const DOC_TRANSFORM_KWARGS = "## Keyword arguments:
- `output_size`: Output size `(width, height)` of the center-crop. Defaults to `$OUTPUT_SIZE`.
- `open_size`: Preferred size `(width, height)` to open the image in using JpegTurbo. Defaults to `$OPEN_SIZE`
- `mean`: Mean of the normalization over color channels. Defaults to `$PYTORCH_MEAN`.
- `std`: Standard deviation of the normalization over color channels Defaults to `$PYTORCH_STD`."

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

#============#
# Transforms #
#============#

"""
    CenterCropNormalize([; output_size, open_size, mean, std])

Preprocessing pipeline center-crops an input image to `output_size` and normalizes it according to `mean` and `std`.
$DOC_TRANSFORM_OUTPUT

$DOC_TRANSFORM_APPLY

$DOC_TRANSFORM_KWARGS
"""
Base.@kwdef struct CenterCropNormalize{T} <: AbstractTransform
    output_size::NTuple{2,Int} = OUTPUT_SIZE
    open_size::NTuple{2,Int} = OPEN_SIZE
    mean::NTuple{3,T} = PYTORCH_MEAN
    std::NTuple{3,T} = PYTORCH_STD
end

function transform(tfm::CenterCropNormalize{T}, path::AbstractString) where {T}
    im = load_image(path, tfm.open_size, T)
    return transform(tfm, im)
end

function transform(tfm::CenterCropNormalize{T}, im::AbstractMatrix{<:Colorant}) where {T}
    im = center_crop(im, tfm.output_size)
    im = normalize!(channelview(im), tfm.mean, tfm.std)
    return PermutedDimsArray(im, (3, 2, 1)) # Convert from Image.jl's CHW to Flux's WHC
end

inverse_transform(tfm::CenterCropNormalize, x) = tensor2img(x, tfm.mean, tfm.std)

"""
    RandomCropNormalize([; output_size, open_size, mean, std])

Preprocessing pipeline crops an input image to `output_size` at a random position and normalizes it according to `mean` and `std`.
$DOC_TRANSFORM_OUTPUT

$DOC_TRANSFORM_APPLY

$DOC_TRANSFORM_KWARGS
"""
Base.@kwdef struct RandomCropNormalize{T} <: AbstractTransform
    output_size::NTuple{2,Int} = OUTPUT_SIZE
    open_size::NTuple{2,Int} = OPEN_SIZE
    mean::NTuple{3,T} = PYTORCH_MEAN
    std::NTuple{3,T} = PYTORCH_STD
end

function transform(tfm::RandomCropNormalize{T}, path::AbstractString) where {T}
    im = load_image(path, tfm.open_size, T)
    return transform(tfm, im)
end

function transform(tfm::RandomCropNormalize{T}, im::AbstractMatrix{<:Colorant}) where {T}
    im = random_crop(im, tfm.output_size)
    im = normalize!(channelview(im), tfm.mean, tfm.std)
    return PermutedDimsArray(im, (3, 2, 1)) # Convert from Image.jl's CHW to Flux's WHC
end

inverse_transform(tfm::RandomCropNormalize, x) = tensor2img(x, tfm.mean, tfm.std)

#===========#
# Utilities #
#===========#

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
load_image(path::AbstractString, T::Type=Float32) = JpegTurbo.jpeg_decode(RGB{T}, path)

function load_image(path::AbstractString, (w, h), T::Type=Float32)
    JpegTurbo.jpeg_decode(RGB{T}, path; preferred_size=(h, w))
end

# Take rectangle of pixels of shape `output_size` at the center of image `im`
function center_crop(im::AbstractMatrix, (w, h))
    # half height, half width of view
    w_half = div(w, 2)
    h_half = div(h, 2)
    w_adjust = adjust_index(w)
    h_adjust = adjust_index(h)
    return @view im[
        ((div(end, 2) - h_half):(div(end, 2) + h_half - h_adjust)) .+ 1,
        ((div(end, 2) - w_half):(div(end, 2) + w_half - w_adjust)) .+ 1,
    ]
end

function random_crop(im::AbstractMatrix, (w_out, h_out))
    h_in, w_in = size(im)
    h_out > h_in &&
        throw(ArgumentError("Image of height $h_in can't be cropped to height $h_out"))
    w_out > w_in &&
        throw(ArgumentError("Image of width $w_in can't be cropped to width $w_out"))

    h_offset = rand(1:(h_in - h_out + 1))
    w_offset = rand(1:(w_in - w_out + 1))
    return @view im[h_offset:(h_offset + h_out - 1), w_offset:(w_offset + w_out - 1)]
end

adjust_index(i::Integer) = ifelse(iszero(i % 2), 1, 0)

function tensor2img(x::AbstractArray{T,N}, mean, std) where {T,N}
    @assert N == 3 || N == 4
    x = PermutedDimsArray(x, (3, 2, 1, 4:N...)) # Convert from WHC[N] to CHW[N]
    return colorview(RGB, inverse_normalize(x, mean, std))
end
