module MinecraftDataStructures

using OrderedCollections
using PooledArrays

export Block, BlockState, AbstractBlockState, CompressedPalettedContainer
export block_id, is_air

abstract type AbstractBlockState end

struct Block <: AbstractBlockState
  id::String
end

struct BlockState <: AbstractBlockState
  id::String
  properties::LittleDict{String, String}
end

block_id(block::Block) = block.id
block_id(block::BlockState) = block.id
is_air(block::AbstractBlockState) = block_id(block) == "minecraft:air"

Base.:(==)(a::BlockState, b::BlockState) = a.id == b.id && a.properties == b.properties
Base.isequal(a::BlockState, b::BlockState) = a.id == b.id && a.properties == b.properties
Base.hash(a::Block, h::UInt64) = hash(a.id, h)
Base.hash(a::BlockState, h::UInt64) = hash(a.id, hash(a.properties, h))

Base.zero(::Type{AbstractBlockState}) = Block("minecraft:air")
Base.zero(::AbstractBlockState) = Block("minecraft:air")
Base.zero(::Type{Block}) = Block("minecraft:air")
Base.zero(::Block) = Block("minecraft:air")
Base.zero(::Type{BlockState}) = BlockState("minecraft:air", LittleDict{String, String}())
Base.zero(::BlockState) = BlockState("minecraft:air", LittleDict{String, String}())

Base.one(::Type{AbstractBlockState}) = Block("minecraft:stone")
Base.one(::AbstractBlockState) = Block("minecraft:stone")
Base.one(::Type{Block}) = Block("minecraft:stone")
Base.one(::Block) = Block("minecraft:stone")
Base.one(::Type{BlockState}) = BlockState("minecraft:stone", LittleDict{String, String}())
Base.one(::BlockState) = BlockState("minecraft:stone", LittleDict{String, String}())

Base.show(io::IO, lr::Block) = print(io, split(lr.id, ":")[end])
Base.show(io::IO, lr::BlockState) = print(io, split(lr.id, ":")[end])

struct CompressedPalettedContainer{T}
  palette::Vector{T}
  data::Array{Int64}
end

function CompressedPalettedContainer(uncompressed::PooledArray{T}, min_bits::Int64) where T
  wordsize = max(min_bits, ceil(Int, log2(length(uncompressed.pool))))
  CompressedPalettedContainer(uncompressed.pool,
    reinterpret.(Int64, BitArray((n - 1) >>> i & 1 == 1 for n in uncompressed.refs for i in 0:wordsize - 1).chunks))
end

function PooledArray(compressed::CompressedPalettedContainer{T}, min_bits::Int64, length::Int) where T
  return PooledArray(compressed, min_bits, (length,))
end

function PooledArray(compressed::CompressedPalettedContainer{T}, min_bits::Int64, size::NTuple{N, Int}) where {N, T}
  @inbounds begin
  wordsize = max(min_bits, ceil(Int, log2(length(compressed.palette))))
  data = ones(UInt32, size)
  shift = 0
  j = 1
  mask = 2^wordsize - 1
  for i in 1:prod(size)
    data[i] += (compressed.data[j] >>> shift) & mask
    if shift + wordsize > 64
      data[i] += (compressed.data[j += 1] >>> (shift - 64)) & mask
      shift = shift + wordsize - 64
    elseif shift + wordsize == 64
      j += 1
      shift = 0
    else
      shift += wordsize
    end
  end
  # TODO: find a way to directly set the PooledArray
  return PooledArray(PooledArrays.RefArray(data), Dict(b => UInt32(i) for (i, b) in enumerate(compressed.palette)), compressed.palette, Threads.Atomic{Int64}(1))
end end

end
