module MinecraftDataStructures

using OrderedCollections

export Block, BlockState, AbstractBlockState
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

end
