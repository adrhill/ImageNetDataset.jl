const IMAGENET_WEBSITE = "https://image-net.org/"
const IMGSIZE = (224, 224)

const NCLASSES = 1_000
const TRAINSET_SIZE = 1_281_167
const VALSET_SIZE = 50_000
const TESTSET_SIZE = 100_000

const ARGUMENTS_SUPERVISED_ARRAY = """
- You can pass a specific `dir` where to load or download the dataset, otherwise uses the default one.
"""

const METHODS_SUPERVISED_ARRAY = """
- `dataset[i]`: Return observation(s) `i` as a named tuple of features and targets.
- `dataset[:]`: Return all observations as a named tuple of features and targets.
- `length(dataset)`: Number of observations.
"""

function __init__imagenet()
    DEPNAME = "ImageNet"
    return register(
        ManualDataDep(
            DEPNAME,
            """The ImageNet 2012 Classification Dataset (ILSVRC 2012-2017) can be downloaded at
            $(IMAGENET_WEBSITE) after signing up and accepting the terms of access.
            It is therefore required that you download this dataset manually.

            Please follow the instructions at
            https://adrhill.github.io/ImageNetDataset.jl/dev/installation/
            """,
        ),
    )
end

"""
    ImageNet(; split=:train, dir=nothing, kwargs...)
    ImageNet([split])

The ImageNet 2012 Classification Dataset (ILSVRC 2012-2017).

This is the most highly-used subset of ImageNet. It spans 1000 object classes and contains
1,281,167 training images, 50,000 validation images and 100,000 test images.
By defaults, each image is in `224 × 224 × 3` format in RGB color space.
This can be changed by modifying the preprocessor `transform`.

# Arguments

$ARGUMENTS_SUPERVISED_ARRAY
- `train_dir`, `val_dir`, `test_dir`, `devkit_dir`: optional subdirectory names of `dir`.
    Default to `"train"`, `"val"`, `"test"` and `"devkit"`.
- `split`: selects the data partition. Can take the values `:train:`, `:val` and `:test`.
    Defaults to `:train`.
- `transform`: preprocessor applied to convert an image file to an array.
    Assumes a file path as input and an array in WHC format as output.
    Defaults to [`CenterCropNormalize`](@ref), which applies a center-cropping view
    and normalization using coefficients from PyTorch's vision models.

# Fields

- `split`: Symbol indicating the selected data partition
- `transform`: Preprocessing pipeline. Can be configured to select output dimensions and type.
- `paths`: paths to ImageNet images
- `targets`: An array storing the targets for supervised learning.
- `metadata`: A dictionary containing additional information on the dataset.

Also refer to [`AbstractTransform`](@ref), [`CenterCropNormalize`](@ref).

# Methods

$METHODS_SUPERVISED_ARRAY
- [`convert2image`](@ref) converts features to `RGB` images.

# Examples

```julia-repl
julia> using ImageNetDataset

julia> dataset = ImageNet(:val);

julia> dataset[1:5].targets
5-element Vector{Int64}:
 1
 1
 1
 1
 1

julia> X, y = dataset[1:5];

julia> size(X)
(224, 224, 3, 5)

julia> X, y = dataset[2000];

julia> convert2image(dataset, X)

julia> dataset.metadata
Dict{String, Any} with 4 entries:
  "class_WNIDs"       => ["n01440764", "n01443537", "n01484850", "n01491361", "n01494475", …
  "class_description" => ["freshwater dace-like game fish of Europe and western Asia noted …
  "class_names"       => Vector{SubString{String}}[["tench", "Tinca tinca"], ["goldfish", "…
  "wnid_to_label"     => Dict("n07693725"=>932, "n03775546"=>660, "n01689811"=>45, "n021008…

julia> dataset.metadata["class_names"][y]
  3-element Vector{SubString{String}}:
   "common iguana"
   "iguana"
   "Iguana iguana"
```

# References

[1]: [Russakovsky et al., ImageNet Large Scale Visual Recognition Challenge](https://arxiv.org/abs/1409.0575)
"""
struct ImageNet{T,S<:AbstractString} # <: SupervisedDataset
    split::Symbol
    transform::T
    paths::Vector{S}
    targets::Vector{Int}
    metadata::Dict{String,Any}
end

ImageNet(; split=:train, kws...) = ImageNet(split; kws...)

function ImageNet(
    split::Symbol;
    transform=CenterCropNormalize(),
    dir=nothing,
    train_dir="train",
    val_dir="val",
    test_dir="test",
    devkit_dir="devkit",
)
    @assert split ∈ (:train, :val, :test)

    depname = "ImageNet"
    root_dir = get_datadep_dir(depname, dir)

    # Load metadata
    metadata_path = joinpath(root_dir, devkit_dir, "data", "meta.mat")
    metadata = get_metadata(metadata_path)

    if split == :train
        paths = get_file_paths(joinpath(root_dir, train_dir))
        @assert length(paths) == TRAINSET_SIZE
    elseif split == :val
        paths = get_file_paths(joinpath(root_dir, val_dir))
        @assert length(paths) == VALSET_SIZE
    else
        paths = get_file_paths(joinpath(root_dir, test_dir))
        @assert length(paths) == TESTSET_SIZE
    end
    targets = [metadata["wnid_to_label"][wnid] for wnid in get_wnids(paths)]
    return ImageNet(split, transform, paths, targets, metadata)
end

Base.length(d::ImageNet) = length(d.paths)

const IMAGENET_MEMORY_WARNING = """Loading the entire ImageNet dataset into memory might not be possible.
    If you are sure you want to load all of ImageNet, use `dataset[1:end]` instead of `dataset[:]`.
    """
Base.getindex(::ImageNet, ::Colon) = throw(ArgumentError(IMAGENET_MEMORY_WARNING))
Base.getindex(d::ImageNet, i) = (features=get_features(d, i), targets=d.targets[i])

get_features(d::ImageNet, i::Integer) = transform(d.transform, d.paths[i])
get_features(d::ImageNet, is::AbstractVector) = StackView(get_features.(Ref(d), is))

"""
    convert2image(dataset::ImageNet, i)
    convert2image(dataset::ImageNet, x)

Convert the observation(s) `i` from dataset `d` to image(s).
It can also convert a numerical array `x`.

# Examples

```julia-repl
julia> using ImageNetDataset, ImageInTerminal

julia> d = ImageNet()

julia> convert2image(d, 1:2)
# You should see 2 images in the terminal

julia> x = d[1].features;

julia> convert2image(MNIST, x) # or convert2image(d, x)
```
"""
convert2image(d::ImageNet, x::AbstractArray) = inverse_transform(d.transform, x)
convert2image(d::ImageNet, i::Integer) = inverse_transform(d.transform, get_features(d, i))
function convert2image(d::ImageNet, is::AbstractRange)
    inverse_transform(d.transform, get_features(d, is))
end

"""
    wnid(dataset, i)

Obtain WordNet ID for given target index `i`.
"""
wnid(d::ImageNet, i) = d.metadata["class_WNIDs"][i]

"""
    class(dataset, i)

Obtain class name for given target index `i`.
"""
class(d::ImageNet, i) = d.metadata["class_names"][i]

"""
    description(dataset, i)

Obtain class class description for given target index `i`.
"""
description(d::ImageNet, i) = d.metadata["class_description"][i]
