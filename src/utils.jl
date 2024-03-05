is_jpeg(path) = endswith(path, ".JPEG")

function get_datadep_dir(depname, dir=nothing)
    @show depname dir
    if isnothing(dir)
        # use DataDeps defaults
        return @datadep_str depname
    elseif isdir(dir)
        return dir
    else
        error("No directory found for ImageNet dataset.")
    end
end

function get_file_paths(path; recursive=true)
    images = String[]
    if isfile(path)
        is_jpeg(path) && push!(images, path)
    elseif isdir(path)
        if recursive
            for (root, _dirs, files) in walkdir(path)
                paths = joinpath.(root, files)
                append!(images, filter(is_jpeg, paths))
            end
        else # not recursive
            paths = readdir(path; join=true)
            append!(images, filter(is_jpeg, paths))
        end
    else
        error("$path must be a directory containing JPEG images.")
    end

    isempty(images) && @warn("No JPEG images found under $path.")
    return images
end

get_metadata(uri::URI) = get_metadata(uri.path)

function get_metadata(path::AbstractString)
    meta = matread(path)["synsets"]

    # Only leaf nodes in WordNet metadata correspond to classes
    is_child = iszero.(meta["num_children"])
    @assert meta["ILSVRC2012_ID"][is_child] == 1:NCLASSES

    # Sort classes by WNID for Metalhead compatibility
    I = sortperm(meta["WNID"][is_child])

    metadata = Dict{String,Any}()
    metadata["class_WNIDs"] = Vector{String}(meta["WNID"][is_child][I]) # WordNet IDs
    metadata["class_names"] = split.(meta["words"][is_child][I], ", ")
    metadata["class_description"] = Vector{String}(meta["gloss"][is_child][I])
    metadata["wnid_to_label"] = Dict(metadata["class_WNIDs"] .=> 1:NCLASSES)
    return metadata
end

# Get WordNet ID from path
get_wnids(paths::AbstractVector{<:AbstractString}) = path_to_wnid.(paths)
path_to_wnid(path::AbstractString) = split(path, "/")[end - 1]
