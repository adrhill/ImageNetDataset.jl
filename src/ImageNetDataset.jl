module ImageNetDataset

# This package is based on MLDatasets.jl PR 146
# https://github.com/JuliaML/MLDatasets.jl/pull/146
# and therefore reuses MIT licensed code and the API design from MLDatasets.
# Copyright (c) 2015 Hiroyuki Shindo and contributors.

using DataDeps
using ImageCore: channelview, colorview
using ImageCore: Colorant, AbstractRGB, RGB
using StackViews: StackView
using JpegTurbo
using MAT: matread # required to read metadata
using URIs: URI

include("preprocess.jl")
include("utils.jl")
include("imagenet.jl")

if !isdefined(Base, :get_extension)
    include("../ext/ImageNetDatasetDataAugmentationExt.jl")
end

__init__() = __init__imagenet()

# Core functionality
export ImageNet
export convert2image
export wnid, class, description

# Preprocessing
export AbstractTransform, CenterCropNormalize, RandomCropNormalize
export transform, inverse_transform
end
