component name="Module" {
	//persist & cache
	application['foundry'] = (structKeyExists(application,'foundry'))? application.foundry : {};
	application.foundry['cache'] = (structKeyExists(application.foundry,'cache'))? application.foundry.cache : {};
	
	this.core_modules = "path,regexp,console,struct,array";
	/**
	 * Creates a CFC instance based upon a relative, absolute or dot notation path.
	*/
	public any function require(x){
		var Path = new lib.Path();
		var cleanPath = Path.normalize(x);
		var parts = Path.splitPath(x);
		var _ = new lib.Underscore();
		var isRelative = !Path.isAbsolute(x);
		var pathSep = Path.getSep();
		var isPath = (cleanPath CONTAINS pathSep);
		var metaData = getComponentMetaData(this);
		var y = Path.splitPath(metaData.path)[2];
		var fullPath = Path.resolve(y,x);

		// 1. If X is a core module,
		//    a. return the core module
		//    b. STOP
		// 2. If X begins with './' or '/' or '../'
		//    a. LOAD_AS_FILE(Y + X)
		//    b. LOAD_AS_DIRECTORY(Y + X)
		// 3. LOAD_FOUNDRY_MODULES(X, dirname(Y))
		// 4. THROW "not found"

		if(isCoreModule(cleanPath)) {
			return createObject("component","lib.#cleanPath#");
		} else if (isPath) {
			if(isDir(fullPath)) {
				
				load_as_directory(fullPath);
			} else if (isFile(fullPath)) {
				load_as_file(fullPath);
			} else {
				load_foundry_modules();
			}
		} else {

		}
	}
	private any function isCoreModule(x) {
		if(listFindNoCase(this.core_modules,x)) return true;

		return false;
	}
	private any function load_as_file(x) {
		if(isFile(x)) {
			return createObject("component",x);
		} else if (isFile(x & ".cfc")) {
			return createObject("component",x);
		} else if (isFile(x & ".cfm")) {
			return fileRead(x);
		}
	}

	private any function load_as_directory(x) {
		// 1. If X/foundry.json is a file,
		//    a. Parse X/foundry.json, and look for "main" field.
		//    b. let M = X + (json main field)
		//    c. LOAD_AS_FILE(M)
		// 2. If X/index.cfc is a file, load X/index.cfc as JavaScript text.  STOP
		// 3. If X/index.cfm is a file, load X/index.cfm as binary addon.  STOP

		if(isFile(x & "/foundry.json")) {
			var config = new lib.config(deserialize(fileRead(x & "/foundry.json")));
			var m = x & config.main;

			load_as_file(m);
		} else if (isFile(x & "/index.cfc")) {
			return createObject("component",x & "/index.cfc");
		} else if (isFile(x & "/index.cfm")) {
			return fileRead(x & "/index.cfm");
		}
		
	}

	private any function load_foundry_modules(x,start) {
		// 1. let DIRS=FOUNDRY_MODULES_PATHS(START)
		// 2. for each DIR in DIRS:
		// 	a. LOAD_AS_FILE(DIR/X)
		// 	b. LOAD_AS_DIRECTORY(DIR/X)

		var dirs = foundry_modules_paths(start);
		for (dir in dirs) {
			if(isDir(fullPath)) {
				load_as_directory(fullPath);
			} else if (isFile(fullPath)) {
				load_as_file(fullPath);
			}
		}
	}

	private any function foundry_modules_paths(start) {
		// 1. let PARTS = path split(START)
		// 2. let ROOT = index of first instance of "foundry_modules" in PARTS, or 0
		// 3. let I = count of PARTS - 1
		// 4. let DIRS = []
		// 5. while I > ROOT,
		//    a. if PARTS[I] = "foundry_modules" CONTINUE
		//    c. DIR = path join(PARTS[0 .. I] + "foundry_modules")
		//    b. DIRS = DIRS + DIR
		//    c. let I = I - 1
		// 6. return DIRS

		var parts = start.splitPath();
	}

	private void function cacheModule() {

	}

	private boolean function isFile(x) {
		var fileInfo = getFileInfo(expandPath(x));

		if(fileInfo.type EQ "file") return true;

		return false;
	}

	private boolean function isDir(x) {
		var fileInfo = getFileInfo(expandPath(x));

		if(fileInfo.type EQ "directory") return true;

		return false;
	}

	public any function noop() {};

}