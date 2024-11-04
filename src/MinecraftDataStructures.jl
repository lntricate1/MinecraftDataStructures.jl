module MinecraftDataStructures

using IndirectArrays

export Block, BlockState, AbstractBlockState, CompressedPalettedContainer

abstract type AbstractBlockState end

struct Block <: AbstractBlockState
  id::String
end

struct BlockState <: AbstractBlockState
  id::String
  properties::Vector{Pair{String, String}}
end

Base.zero(::Type{AbstractBlockState}) = Block("minecraft:air")
Base.zero(::AbstractBlockState) = Block("minecraft:air")
Base.zero(::Type{Block}) = Block("minecraft:air")
Base.zero(::Block) = Block("minecraft:air")
Base.zero(::Type{BlockState}) = BlockState("minecraft:air", Pair{String, String}[])
Base.zero(::BlockState) = BlockState("minecraft:air", Pair{String, String}[])

Base.one(::Type{AbstractBlockState}) = Block("minecraft:stone")
Base.one(::AbstractBlockState) = Block("minecraft:stone")
Base.one(::Type{Block}) = Block("minecraft:stone")
Base.one(::Block) = Block("minecraft:stone")
Base.one(::Type{BlockState}) = BlockState("minecraft:stone", Pair{String, String}[])
Base.one(::BlockState) = BlockState("minecraft:stone", Pair{String, String}[])

struct CompressedPalettedContainer{T}
  palette::Vector{T}
  data::Array{Int64}
end

function CompressedPalettedContainer(uncompressed::IndirectArray{<:AbstractBlockState})
  wordsize = ceil(Int, log2(length(uncompressed.values)))
  CompressedPalettedContainer(uncompressed.values,
    reinterpret.(Int64, BitArray((n - 1) >>> i & 1 == 1 for n in uncompressed.index for i in 0:wordsize - 1).chunks))
end

function IndirectArray(compressed::CompressedPalettedContainer, len::Int)
  wordsize = max(1, ceil(Int, log2(length(compressed.palette))))
  data = ones(UInt64, len)
  shift = 0
  j = 1
  mask = 2^wordsize - 1
  for i in 1:len
    data[i] += (compressed.data[j] >>> shift) & mask
    if shift + wordsize >= 64
      data[i] += (compressed.data[j += 1] >>> (shift - 64)) & mask
      shift = shift + wordsize - 64
    else
      shift += wordsize
    end
  end
  return IndirectArray(data, compressed.palette)
end

end
