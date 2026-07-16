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
@export var tileMapDetail: TileMapLayer
@export var tileMapHeight: TileMapLayer
@export var tileMapWalls: TileMapLayer
@export var tileMapFloors: TileMapLayer
@export var tileMapCeiling: TileMapLayer

# Creates gridmap creation button, sets it to "create_gridmap" function
@export_tool_button("Create Gridmap From Tilemaps") var gridMapFunction = create_gridmap

# Variable declaration
var size = Vector2()
var cellInfo
var heightInfo
var modelName
var modelType
var modelDirection
var heightVal
var mapSize

# Gridmaps
var northWall
var southWall
var eastWall
var westWall
var levelFloor
var levelCeiling

# Gridmap Data
var tileMapWallData: PackedByteArray
var tileMapFloorData: PackedByteArray
var tileMapCeilingData: PackedByteArray

# Meshlibs
var northMeshLib: MeshLibrary
var southMeshLib: MeshLibrary
var eastMeshLib: MeshLibrary
var westMeshLib: MeshLibrary
var floorMeshLib: MeshLibrary
var ceilingMeshLib: MeshLibrary

func create_gridmap():
	
	northWall = get_node("NorthWall")
	southWall = get_node("SouthWall")
	eastWall = get_node("EastWall")
	westWall = get_node("WestWall")
	
	levelFloor = get_node("Floor")
	levelCeiling = get_node("Ceiling")
	
	# Get size of tilemap, add one to both axis because it's for some
	# reason number one short
	size = tileMapWalls.get_used_rect().size

	size[0] += 1
	size[1] += 1
	
	# Get mesh library from self
	northMeshLib = northWall.get_mesh_library()
	southMeshLib = southWall.get_mesh_library()
	eastMeshLib = eastWall.get_mesh_library()
	westMeshLib = westWall.get_mesh_library()
	
	floorMeshLib = levelFloor.get_mesh_library()
	ceilingMeshLib = levelCeiling.get_mesh_library()
	
	# Clears self to avoid corruption and errors
	northWall.clear()
	southWall.clear()
	eastWall.clear()
	westWall.clear()
	levelFloor.clear()
	
	# Get the wall tilemap data as a PackedByteArray
	tileMapWallData = tileMapWalls.get_tile_map_data_as_array()
	# Get the floor tilemap data as a PackedByteArray
	tileMapFloorData = tileMapFloors.get_tile_map_data_as_array()
	tileMapCeilingData = tileMapCeiling.get_tile_map_data_as_array()

	mapSize = tileMapWallData.size()

	# Checks each cell/entry in tileFloorData
	for I in range(tileMapFloorData.size()):
		# Gets the info of the current cell
		cellInfo = tileMapFloors.get_cell_tile_data( Vector2( I%size[0], 
			int(I/size[0]) ) )
		# Checks if cell is blank or not, if so, ignore 
		if cellInfo != null:
			# Gets provided model name from tile, then converts to string
			modelName = String(cellInfo.get_custom_data("Model"))
			# Checks of tile has a model name, if so, add that model to
			# current cell
			if modelName != "":
				if modelName.begins_with("FloorDebug"):
					SetCellFloor("FloorDebug", I)
				if modelName.begins_with("BasicFloor"):
					SetCellFloor("BasicFloor", I)
				if modelName.begins_with("ClassicFloor"):
					SetCellFloor("ClassicFloor", I)
				if modelName.begins_with("CarpetFloor"):
					SetCellFloor("CarpetFloor", I)
				if modelName.begins_with("PlaygroundFloor"):
					SetCellFloor("PlaygroundFloor", I)
				if modelName.begins_with("Sidewalk"):
					SetCellFloor("Sidewalk", I)
				if modelName.begins_with("Grass"):
					SetCellFloor("Grass", I)

	# Checks each cell/entry in tileMapData
	for I in range(tileMapWallData.size()):
		# Gets the info of the current cell
		cellInfo = tileMapWalls.get_cell_tile_data( Vector2( I%size[0], 
			int(I/size[0]) ) )
		heightInfo = tileMapHeight.get_cell_tile_data( Vector2( I%size[0], 
			int(I/size[0]) ) )
		
		# Checks if cell is blank or not, if so, ignore 
		if cellInfo != null:
			# Gets provided model name from tile, then converts to string
			modelName = String(cellInfo.get_custom_data("Model"))
			
			if(heightInfo != null):
				heightVal = heightInfo.get_custom_data("Value")
			else:
				heightVal = 1
			# Checks of tile has a model name, if so, add that model to
			# current cell
			
			modelType = modelName.findn("tile")
			modelType = modelName.erase(modelType, modelName.length())
			
			modelDirection = modelName.get_slice("Tile", 1)
			modelDirection = modelDirection.to_lower()
			
			var H = 0
			while H < heightVal: 
				if modelName != "":
					if modelName.begins_with("Debug"):
						checkWall("Debug", modelDirection, I, H)
					if modelName.begins_with("Normal"):
						checkWall("WallClassic", modelDirection, I, H)
					if modelName.begins_with("YellowC"):
						checkWall("YellowClassroom", modelDirection, I, H)
					if modelName.begins_with("Wood"):
						checkWall("WoodWall", modelDirection, I, H)
					if modelName.begins_with("RedC"):
						checkWall("RedClassroom_", modelDirection, I, H)
					if modelName.begins_with("Cafeteria"):
						if(H == 0):
							checkWall("CafeteriaWall1", modelDirection, I, H)
						else:
							checkWall("CafeteriaWall2", modelDirection, I, H)
					if modelName.begins_with("Outside"):
						checkWall("OutsideWall", modelDirection, I, H)
				H += 1
	
	# Checks each cell/entry in tileCeilingData
	for I in range(tileMapCeilingData.size()):
		# Gets the info of the current cell
		cellInfo = tileMapCeiling.get_cell_tile_data( Vector2( I%size[0], 
			int(I/size[0]) ) )
		# Checks if cell is blank or not, if so, ignore 
		if cellInfo != null:
			# Gets provided model name from tile, then converts to string
			modelName = String(cellInfo.get_custom_data("Model"))
			# Checks of tile has a model name, if so, add that model to
			# current cell
			if modelName != "":
				if modelName.begins_with("CeilingDebug"):
					SetCellCeiling("CeilingDebug", I, 0)
				if modelName.begins_with("BasicCeiling"):
					SetCellCeiling("BasicCeiling", I, 0)
				if modelName.begins_with("VentCeiling"):
					SetCellCeiling("VentCeiling", I, 0)
				if modelName.begins_with("FalseLight"):
					SetCellCeiling("FalseLight", I, 0)

func SetCellCeiling(type, index, tileHeight):
	levelCeiling.set_cell_item(Vector3i(index%size[0], tileHeight, int(index/size[0])), 
	ceilingMeshLib.find_item_by_name(type), 0)

func SetCellFloor(type, index):
	levelFloor.set_cell_item(Vector3i(index%size[0], 0, int(index/size[0])), 
	floorMeshLib.find_item_by_name(type), 0)

func checkWall(type, direction, index, tileHeight):
	if direction == "blank":
		pass
	else:
		if direction.contains('n'):
			northWall.set_cell_item(Vector3i(index%size[0], tileHeight, int(index/size[0])), 
				northMeshLib.find_item_by_name(type), 0)
		if direction.contains('s'):
			southWall.set_cell_item(Vector3i(index%size[0], tileHeight, int(index/size[0])), 
				southMeshLib.find_item_by_name(type), 0)
		if direction.contains('e'):
			eastWall.set_cell_item(Vector3i(index%size[0], tileHeight, int(index/size[0])), 
				eastMeshLib.find_item_by_name(type), 0)
		if direction.contains('w'):
			westWall.set_cell_item(Vector3i(index%size[0], tileHeight, int(index/size[0])), 
				westMeshLib.find_item_by_name(type), 0)
