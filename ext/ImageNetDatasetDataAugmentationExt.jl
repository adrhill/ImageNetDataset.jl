module ImageNetDatasetDataAugmentationExt

using ImageNetDataset
using DataAugmentation: Transform, Image, apply, itemdata

function ImageNetDataset.transform(tfm::Transform, path)
    im = ImageNetDataset.load_image(path)
    return itemdata(apply(tfm, Image(im)))
end

function ImageNetDataset.inverse_transform(tfm::Transform, x)
    error("Preprocessing transformations from DataAugmentation.jl don't provide an inverse
          and can't be used with `convert2image`.")
end

end # module
