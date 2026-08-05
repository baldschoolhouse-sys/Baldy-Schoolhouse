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

const optNSEW = ["","N","S","E","W"]

# Creates gridmap creation button, sets it to "create_gridmap" function
@export_tool_button("Create Gridmap From Tilemaps") var gridMapFunction = create_gridmap

var bellObject

var objects
var bellNodes

var cellInfo
var heightInfo
var detailInfo

var modelName
var modelType
var modelDirection
var heightVal
var cellPos

var wallSize
var heightSize 
var floorSize 
var ceilingSize
var detailSize
var totalMapTiles
var mapSize

var wallVariant

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

func create_node_bases(input):
	if(!objects.has_node(input)):
		var packedNode = PackedScene.new()
		var newNode3D = Node3D.new()
		newNode3D.position = Vector3(0, 0, 0)
		newNode3D.name = input
		packedNode.pack(newNode3D)
		var instantiatedNode = packedNode.instantiate()

		objects.add_child(instantiatedNode)
		instantiatedNode.set_owner(EditorInterface.get_edited_scene_root())

func create_node(object, pos, rot, destination):
	var instantiatedNode = object.instantiate()
	instantiatedNode.position = pos
	instantiatedNode.rotation = rot
	instantiatedNode.name = instantiatedNode.name + str(destination.get_child_count())
	
	destination.add_child(instantiatedNode)
	instantiatedNode.set_owner(EditorInterface.get_edited_scene_root())

func create_bell(pos, rot):
	#if ( int(rot) % 2 ) != 0:
	create_node(
		bellObject, 
		Vector3( 
			( pos[0] * 2 ) + ( ( int(rot) % 2 ) * (
				( 0.12 * bell_math(rot, 0)  ) ) ) + 1,
			0, 
			( pos[1] * 2 ) + ( ( int(rot) % 2 ) * (
				( 0.12 * bell_math(rot, 1)  ) ) ) + 1
		), 
		Vector3(0, -deg_to_rad(rot * (45.0)), 0), 
		bellNodes
		)
		#print(rot)
		#print( str( bell_math(rot, 0) ) + " " + str( bell_math(rot, 1) ))

func bell_math(rot, type):
	return ( ( ( int( (rot + (type*2)) / (4) ) + 1 - type) % 2) * 2) - 1
		
func clear_nodes(object):
	for n in object.get_children():
		n.free()

func create_gridmap():
	
	bellObject = load("res://entities/bell/bell.tscn")
	
	northWall = get_node("NorthWall")
	southWall = get_node("SouthWall")
	eastWall = get_node("EastWall")
	westWall = get_node("WestWall")
	
	levelFloor = get_node("Floor")
	levelCeiling = get_node("Ceiling")
	
	objects = get_node("DetailAndInteractive")

	#size[0] += 1
	#size[1] += 1
	
	# Get mesh library from self
	northMeshLib = northWall.get_mesh_library()
	southMeshLib = southWall.get_mesh_library()
	eastMeshLib = eastWall.get_mesh_library()
	westMeshLib = westWall.get_mesh_library()
	
	floorMeshLib = levelFloor.get_mesh_library()
	ceilingMeshLib = levelCeiling.get_mesh_library()
	
	create_node_bases("Doors")
	bellNodes = objects.get_node("Doors")

	create_node_bases("Windows")
	bellNodes = objects.get_node("Windows")
	
	create_node_bases("Bells")
	bellNodes = objects.get_node("Bells")

	# Clears self to avoid corruption and errors
	northWall.clear()
	southWall.clear()
	eastWall.clear()
	westWall.clear()
	levelFloor.clear()
	levelCeiling.clear()
	
	clear_nodes(bellNodes)

	# Get the wall tilemap data as a PackedByteArray
	tileMapWallData = tileMapWalls.get_tile_map_data_as_array()
	# Get the floor tilemap data as a PackedByteArray
	tileMapFloorData = tileMapFloors.get_tile_map_data_as_array()
	tileMapCeilingData = tileMapCeiling.get_tile_map_data_as_array()
	
	# Get size of tilemap, add one to both axis because it's for some
	# reason number one short
	var usedCellInfo = [
		tileMapWalls.get_used_cells(),
		tileMapFloors.get_used_cells(),
		tileMapDetail.get_used_cells(),
		tileMapCeiling.get_used_cells()
	]
	
	if(usedCellInfo[0].size() != 0):
		wallSize = tileMapWalls.get_used_rect().size + usedCellInfo[0][0]
	else:
		wallSize = tileMapWalls.get_used_rect().size
	if(usedCellInfo[1].size() != 0):
		floorSize = tileMapFloors.get_used_rect().size + usedCellInfo[1][0]
	else:
		floorSize = tileMapWalls.get_used_rect().size
	#if(usedCellInfo[2].size() != 0):
	#	detailSize = tileMapDetail.get_used_rect().size + usedCellInfo[2][0]
	#else:
	#	detailSize = tileMapWalls.get_used_rect().size
	if(usedCellInfo[3].size() != 0):
		ceilingSize = tileMapCeiling.get_used_rect().size + usedCellInfo[3][0]
	else:
		ceilingSize = tileMapWalls.get_used_rect().size

	#ceilingSize = tileMapCeiling.get_used_rect().size + Vector2i(1, 1)
	heightSize = tileMapHeight.get_used_rect().size + Vector2i(1, 1)
	detailSize = tileMapDetail.get_used_rect().size

	if(wallSize[0] == 0):
		wallSize = Vector2i(1, 1)

	mapSize = Vector2(max(
		wallSize[0], 
		heightSize[0],
		floorSize[0],
		ceilingSize[0],
		detailSize[0]
	),
	max(
		wallSize[1], 
		heightSize[1],
		floorSize[1],
		ceilingSize[1],
		detailSize[1]
	)
	)
	
	print(mapSize)
	totalMapTiles = (mapSize[0]) * (mapSize[1])

	# Checks each cell/entry in tileFloorData
	for I in range(totalMapTiles):
		# Gets the info of the current cell
		cellInfo = tileMapFloors.get_cell_tile_data( Vector2( I%floorSize[0], 
			int(I/floorSize[0]) ) )
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
				if modelName.begins_with("Asphalt"):
					SetCellFloor("Asphalt", I)
				if modelName.begins_with("GymFloor"):
					SetCellFloor("Gymnasium_Floor", I)
					
	# Checks each cell/entry in tileMapData
	for I in range(totalMapTiles):
		# Gets the info of the current cell
			
		cellPos = Vector2( I%wallSize[0], int(I/wallSize[0]))
		cellInfo = tileMapWalls.get_cell_tile_data(cellPos) 
		
		heightInfo = tileMapHeight.get_cell_tile_data(cellPos)
		detailInfo = tileMapDetail.get_cell_tile_data(cellPos)

		#print("ci: " + str(cellInfo))

		# Checks if cell is blank or not, if so, ignore 
		if cellInfo != null:
			# Gets provided model name from tile, then converts to string
			modelName = String(cellInfo.get_custom_data("Model"))
			
			if(heightInfo != null):
				heightVal = heightInfo.get_custom_data("Value")
			else:
				heightVal = 1
				
			if(detailInfo != null):
				detailInfo = detailInfo.get_custom_data("Asset")
			else:
				detailInfo = "blank"
				
			# Checks of tile has a model name, if so, add that model to
			# current cell
			#print("mn1: " + str( modelType ) )
			modelType = modelName.findn("tile")
			#print("mt: " + str( modelType ) )
			#print("mn2: " + str( modelName ) )
			#print("mnl: " + str( modelName.length() ) )
			modelType = modelName.erase(modelType, modelName.length())
			
			if detailInfo.begins_with("Bell-"):
				create_bell(
					Vector2(I%wallSize[0], int(I/wallSize[0])), 
					int(detailInfo.get_slice("-", 1))
				)
			
			if detailInfo.begins_with("Door-"):
				wallVariant = ["Doorhole", detailInfo.get_slice("-", 3)]
				#print(wallVariant)
			else:
				wallVariant = ["", ""]
			
			modelDirection = modelName.get_slice("Tile", 1)
			modelDirection = modelDirection.to_lower()
			
			var H = 0
			while H < heightVal: 
				if modelName != "":
					if(H == 0):
						setWall(modelName, modelDirection, I, H, wallVariant)
					else:
						setWall(modelName, modelDirection, I, H)
					pass
				H += 1
			
			var heightInfoNSEW = [
				tileMapHeight.get_cell_tile_data( Vector2( cellPos[0], cellPos[1]-1 )),
				tileMapHeight.get_cell_tile_data( Vector2( cellPos[0], cellPos[1]+1 )),
				tileMapHeight.get_cell_tile_data( Vector2( cellPos[0]+1, cellPos[1] )),
				tileMapHeight.get_cell_tile_data( Vector2( cellPos[0]-1, cellPos[1] ))
			]
			
			#var heightInfoNSEW = [
			#	tileMapHeight.get_cell_tile_data( Vector2( I, I) ),
			#	tileMapHeight.get_cell_tile_data( Vector2( I, I) ),
			#	tileMapHeight.get_cell_tile_data( Vector2( I, I) ),
			#	tileMapHeight.get_cell_tile_data( Vector2( I, I) )
			#	]
			
			#print(heightInfoNSEW)
			
			var heightValNSEW = []
			
			for hi in heightInfoNSEW:
				if hi != null:
					heightValNSEW.append(hi.get_custom_data("Value"))
				else:
					heightValNSEW.append(heightVal)
			
			#print(heightValNSEW)
			#print("H : " + str(H))
			#print("Mx : " + str( min(heightValNSEW[0], heightValNSEW[1], heightValNSEW[2], heightValNSEW[3]) ) )
			
			while H > min(heightValNSEW[0], heightValNSEW[1], heightValNSEW[2], heightValNSEW[3]): 
				modelDirection = ""
				if modelName != "":
					if(H > heightValNSEW[0]):
						modelDirection += "n"
					if(H > heightValNSEW[1]):
						modelDirection += "s"
					if(H > heightValNSEW[2]):
						modelDirection += "e"
					if(H > heightValNSEW[3]):
						modelDirection += "w"
					#print(modelDirection)
					#print(modelName)
					setWall(modelName, modelDirection, I, H-1)
				H -= 1
			

				
	# Checks each cell/entry in tileCeilingData
	for I in range(totalMapTiles):
		# Gets the info of the current cell
		cellInfo = tileMapCeiling.get_cell_tile_data( Vector2( I%ceilingSize[0], 
			int(I/ceilingSize[0]) ) )
		heightInfo = tileMapHeight.get_cell_tile_data( Vector2( I%ceilingSize[0], 
			int(I/ceilingSize[0]) ) )
		
		if(heightInfo != null):
			heightVal = heightInfo.get_custom_data("Value")
		else:
			heightVal = 1
			
		# Checks if cell is blank or not, if so, ignore 
		if cellInfo != null:
			# Gets provided model name from tile, then converts to string
			modelName = String(cellInfo.get_custom_data("Model"))
			# Checks of tile has a model name, if so, add that model to
			# current cell
			if modelName != "":
				if modelName.begins_with("CeilingDebug"):
					SetCellCeiling("CeilingDebug", I, heightVal-1)
				if modelName.begins_with("BasicCeiling"):
					SetCellCeiling("BasicCeiling", I, heightVal-1)
				if modelName.begins_with("VentCeiling"):
					SetCellCeiling("VentCeiling", I, heightVal-1)
				if modelName.begins_with("FalseLight"):
					SetCellCeiling("FalseLight", I, heightVal-1)
	

func SetCellCeiling(type, index, tileHeight):
	levelCeiling.set_cell_item(Vector3i(index%ceilingSize[0], tileHeight, int(index/ceilingSize[0])), 
	ceilingMeshLib.find_item_by_name(type), 0)

func SetCellFloor(type, index):
	levelFloor.set_cell_item(Vector3i(index%floorSize[0], 0, int(index/floorSize[0])), 
	floorMeshLib.find_item_by_name(type), 0)

func setWall(mn, md, i, h, wallV = ["", ""]):
	if mn.begins_with("Debug"):
		createWall("DebugWall", md, wallV, i, h, 1)
	if mn.begins_with("Normal"):
		createWall("WallClassic", md, wallV, i, h)
	if mn.begins_with("YellowC"):
		createWall("YellowClassroom", md, wallV, i, h)
	if mn.begins_with("Wood"):
		createWall("WoodWall", md, wallV, i, h)
	if mn.begins_with("RedC"):
		createWall("RedClassroom", md, wallV, i, h)
	if mn.begins_with("Cafeteria"):
		if(h == 0):
			createWall("CafeteriaWall1", md, wallV, i, h)
		else:
			createWall("CafeteriaWall2", md, wallV, i, h)
	if mn.begins_with("Outside"):
		createWall("OutsideWall", md, wallV, i, h)

func createWall(type, direction, wallV, index, tileHeight, ad = 0):
	var wallVarDir = ["", "", "", "", ""]
	if(direction.contains(wallV[1].to_lower())):
		wallVarDir[optNSEW.find(wallV[1])] = wallV[0]
	#if direction == "blank":
	#	pass
	
	if direction != "blank":
		if direction.contains('n'):
			northWall.set_cell_item(Vector3i(index%wallSize[0], tileHeight, int(index/wallSize[0])), 
				northMeshLib.find_item_by_name(type + optNSEW[1 * ad] + wallVarDir[1]), 0)
		if direction.contains('s'):
			southWall.set_cell_item(Vector3i(index%wallSize[0], tileHeight, int(index/wallSize[0])), 
				southMeshLib.find_item_by_name(type + optNSEW[2 * ad] + wallVarDir[2]), 0)
		if direction.contains('e'):
			eastWall.set_cell_item(Vector3i(index%wallSize[0], tileHeight, int(index/wallSize[0])), 
				eastMeshLib.find_item_by_name(type + optNSEW[3 * ad] + wallVarDir[3]), 0)
		if direction.contains('w'):
			westWall.set_cell_item(Vector3i(index%wallSize[0], tileHeight, int(index/wallSize[0])), 
				westMeshLib.find_item_by_name(type + optNSEW[4 * ad] + wallVarDir[4]), 0)
