@tool
extends GridMap

# IMPORTANT!!!
# Make sure not to edit the gridmap directly as it will get overwritten
# whem being updated from the gridmap!

# Also!
# Make sure to add cafeteria border tiles (CB) in between normal and
# cafeteria tiles or else there will be missing some wall seperating the
# different heights

# HOW TO USE (By Jack)
# 1. Create Gridmap in scene, then add this script and set it's mesh libary
# to "wallGridmap.tres"
# 2. Then add a TileMapLayer, then set it's tileset to "wallTileSet.tres"
# 3. Then, add the tiles you want which is best done by using a mix of
# the terrains and direct tile placement
# 4. Whenever you update the tilemap, push the "Create Gridmap From Tilemap"
# button
# 5. Also, make sure when you start the game, the TileMap is hidden, or 
# you get a weird map in the corner of the screen

# Adds TileMapLayer parameter
@export var tilemap: TileMapLayer

# Creates gridmap creation button, sets it to "create_gridmap" function
@export_tool_button("Create Gridmap From Tilemap") var gridMapFunction = create_gridmap

# Variable declaration
var meshLib: MeshLibrary
var tileMapData: PackedByteArray
var size = Vector2()
var cellInfo
var modelName

func create_gridmap():
	
	# Get size of tilemap, add one to both axis because it's for some
	# reason number one short
	size = tilemap.get_used_rect().size

	size[0] += 1
	size[1] += 1
	
	# Get mesh library from self
	meshLib = get_mesh_library()
	
	# Clears self to avoid corruption and errors
	self.clear()
	
	# Get the tilemap data as a PackedByteArray
	tileMapData = tilemap.get_tile_map_data_as_array()
	
	# Checks each cell/entry in tileMapData
	for I in range(tileMapData.size()):
		# Gets the info of the current cell
		cellInfo = tilemap.get_cell_tile_data( Vector2( I%size[0], 
			int(I/size[0]) ) )
		# Checks if cell is blank or not, if so, ignore 
		if cellInfo != null:
			# Gets provided model name from tile, then converts to string
			modelName = String(cellInfo.get_custom_data("Model"))
			# Checks of tile has a model name, if so, add that model to
			# current cell
			if modelName != "":
				set_cell_item(Vector3i(I%size[0], 0, int(I/size[0])), 
					meshLib.find_item_by_name(modelName), 0)
