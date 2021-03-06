package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import sys.io.File;
import sys.FileSystem;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import lime.utils.Assets;
import flixel.FlxSprite;
import flash.media.Sound;
import openfl.system.System;
import openfl.geom.Matrix;
import openfl.display.Bitmap;
import openfl.display.PixelSnapping;

using StringTools;

class Paths
{
	public static var charPath:Array<String> = [];

	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;
	static public var currentModDirectory:String = '';

	#if desktop
	public static var ignoreModFolders:Array<String> = [
//		'BETADCIU',
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];
	#end

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function returnGraphic(key:String, ?library:String = null) 
	{
		var path:String;

		if (Assets.exists(getPath('images/$key.png', IMAGE, 'shared')))
			library = 'shared';

		path = getPath('images/$key.png', IMAGE, library);
	
		if (Assets.exists(path)) 
		{
			if(!currentTrackedAssets.exists(key)) 
			{
				var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, key);
				currentTrackedAssets.set(key, newGraphic);
			}
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}

		trace('you failed dipshit');
		return null;	
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') 
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type) || FileSystem.exists(levelPath))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type) || FileSystem.exists(levelPath))
				return levelPath;		
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String = "")
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function lua(key:String,?library:String)
	{
		if(FileSystem.exists(Paths.modFolders('data/' + key + '.lua')))
			return Paths.modFolders('data/' + key + '.lua');

		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function lua2(key:String,?library:String)
	{
		if(FileSystem.exists(Paths.modFolders(key +'.lua')))
			return Paths.modFolders(key +'.lua');

		return getPath('$key.lua', TEXT, library);
	}

	inline static public function stageLua(key:String,?library:String)
	{
		if(FileSystem.exists(Paths.modFolders('stages/' + key + '.lua')))
			return Paths.modFolders('stages/' + key + '.lua');

		return getPath('stages/$key.lua', TEXT, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		if(FileSystem.exists(Paths.modFolders('data/' + key +'.txt')))
			return Paths.modFolders('data/' + key +'.txt');

		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function txtNew(key:String, ?library:String)
	{
		if(FileSystem.exists(Paths.modFolders(key +'.txt')))
			return Paths.modFolders(key +'.txt');

		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xmlNew(key:String, ?library:String)
	{
		if(FileSystem.exists(Paths.modFolders(key +'.xml')))
			return Paths.modFolders(key +'.xml');

		return getPath('$key.xml', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		if(FileSystem.exists(Paths.modFolders('data/' + key +'.xml')))
			return Paths.modFolders('data/' + key +'.xml');

		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		if(FileSystem.exists(Paths.modFolders('data/' + key +'.json')))
			return Paths.modFolders('data/' + key +'.json');

		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		if (FileSystem.exists(Paths.modsSounds('sounds', key)))
		{
			returnSound('sounds', key);
			return Paths.modsSounds('sounds', key);
		}
	
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function video(key:String, ?library:String)
	{
		if(FileSystem.exists(Paths.modFolders('videos/' + key +'.mp4')))
			return Paths.modFolders('videos/' + key +'.mp4');

		return getPath('videos/$key.mp4', BINARY, library);
	}

	inline static public function inst2(song:String, ?library:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
			case 'scary-swings': songLowercase = 'scary swings';
			case 'my-sweets': songLowercase = 'my sweets';
		}

		var pre:String = "";
		var suf:String = "";

		if (Main.noCopyright && songLowercase == "sharkventure")
			pre = 'Alt_';		
		if (PlayState.isNeonight)
			suf = 'NN';
		if (PlayState.isVitor)		
			suf = 'V';
		if (PlayState.isBETADCIU && PlayState.storyDifficulty == 5 && (Assets.exists('songs:assets/songs/${songLowercase}/'+'Inst'+'Guest'+'.$SOUND_EXT') || FileSystem.exists(Paths.modsSounds('songs', '${songLowercase}/'+pre+'InstGuest'))))		
			suf = 'Guest';

		if (FileSystem.exists(Paths.modsSounds('songs', '${songLowercase}/'+pre+'Inst'+suf)))
		{
			returnSound('songs', '${songLowercase}/'+pre+'Inst'+suf);
			return Paths.modsSounds('songs', '${songLowercase}/'+pre+'Inst'+suf);
		}

		return FileSystem.absolutePath('assets/songs/${songLowercase}/'+pre+'Inst'+suf+'.$SOUND_EXT');
	}

	inline static public function voices2(song:String, ?library:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
			case 'scary-swings': songLowercase = 'scary swings';
			case 'my-sweets': songLowercase = 'my sweets';
		}

		var pre:String = "";
		var suf:String = "";

		if (Main.noCopyright && songLowercase == "sharkventure")
			pre = 'Alt_';		
		if (PlayState.isNeonight)
			suf = 'NN';
		if (PlayState.isVitor)		
			suf = 'V';
		if (PlayState.isBETADCIU && PlayState.storyDifficulty == 5 && (Assets.exists('songs:assets/songs/${songLowercase}/'+'Voices'+'Guest'+'.$SOUND_EXT') || FileSystem.exists(Paths.modsSounds('songs', '${songLowercase}/'+pre+'VoicesGuest'))))		
			suf = 'Guest';

		if (FileSystem.exists(Paths.modsSounds('songs', '${songLowercase}/'+pre+'Voices'+suf)))
		{
			returnSound('songs', '${songLowercase}/'+pre+'Voices'+suf);
			return Paths.modsSounds('songs', '${songLowercase}/'+pre+'Voices'+suf);
		}
			
		return FileSystem.absolutePath('assets/songs/${songLowercase}/'+pre+'Voices'+suf+'.$SOUND_EXT');
	}

	inline static public function voices(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
			switch (songLowercase) {
				case 'dad-battle': songLowercase = 'dadbattle';
				case 'philly-nice': songLowercase = 'philly';	
				case 'scary-swings': songLowercase = 'scary swings';
			}

		var pre:String = "";
		var suf:String = "";

		if (PlayState.isNeonight)
			suf = 'NN';
		if (PlayState.isVitor)
			suf = 'V';
		if (PlayState.isBETADCIU && PlayState.storyDifficulty == 5)		
			suf = 'Guest';
		if (PlayState.isBETADCIU && (songLowercase == 'kaboom' || songLowercase == 'triple-trouble'))		
			suf = 'BETADCIU';
		if (Main.isMegalo && songLowercase == 'hill-of-the-void')		
			suf = 'Megalo';

		return 'songs:assets/songs/${songLowercase}/'+pre+'Voices'+suf+'.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
			switch (songLowercase) {
				case 'dad-battle': songLowercase = 'dadbattle';
				case 'philly-nice': songLowercase = 'philly';
				case 'scary-swings': songLowercase = 'scary swings';
				case 'my-sweets': songLowercase = 'my sweets';
			}

		var pre:String = "";
		var suf:String = "";

		if (Main.noCopyright && song.toLowerCase() == "sharkventure")
			pre = 'Alt_';		
		if (PlayState.isNeonight)
			suf = 'NN';
		if (PlayState.isVitor)		
			suf = 'V';
		if (PlayState.isBETADCIU && PlayState.storyDifficulty == 5 && Assets.exists('songs:assets/songs/${songLowercase}/'+'Inst'+'Guest'+'.$SOUND_EXT'))		
			suf = 'Guest';
	
		return 'songs:assets/songs/${songLowercase}/'+pre+'Inst'+suf+'.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		/*	var returnAsset:FlxGraphic = returnGraphic(key, library);

		if (FileSystem.exists(Paths.modsImages(key)))	
		{
			if (!Paths.currentTrackedAssets.exists(key))
				cacheImage(key);

			return Paths.modsImages(key);
		}*/
			
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function image2(key:String, ?library:String)
	{
		return getPath('images/$key', IMAGE, library);
	}

	inline static public function jsonNew(key:String, ?library:String)
	{
		if(FileSystem.exists(Paths.modFolders(key +'.json')))
			return Paths.modFolders(key +'.json');

		return getPath('$key.json', TEXT, library);
	}

	inline static public function font(key:String)
	{
		#if desktop
			var file:String = modsFont(key);
			if(FileSystem.exists(file)) {
				return file;
			}
		#end

		return 'assets/fonts/$key';
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static var localTrackedAssets:Array<String> = [];

	//idk if this shit works. holy s%$t it did.
	public static function clearStoredMemory(?cleanUnused:Bool = false) {
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached.
		for (key in currentTrackedSounds.keys()) {
			if (!localTrackedAssets.contains(key) 
			&& !dumpExclusions.contains(key) && key != null) {
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
		openfl.Assets.cache.clear("shared:assets/shared/images/characters/jsons");
		openfl.Assets.cache.clear("assets/images/characters/jsons");
		openfl.Assets.cache.clear("mods");
		openfl.Assets.cache.clear("assets/stages");
		trace ('cleared');
	}

	public static var dumpExclusions:Array<String> = [];

	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) 
				&& !dumpExclusions.contains(key)) {
				// get rid of it
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null) {
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}
		// run the garbage collector for good measure lmfao
		System.gc();
	}


	// for uncaching midsong?
	public static function clearStoredMemory2(key:String) {
		// clear anything not in the tracked assets list
		trace ('uncaching ' + key);
		@:privateAccess

		var obj = FlxG.bitmap._cache.get(key);
		
		if (obj != null)
		{
			openfl.Assets.cache.removeBitmapData(key);
			@:privateAccess
			FlxG.bitmap._cache.remove(key);
			obj.destroy();

			if(currentTrackedAssets.exists(key)) 
				currentTrackedAssets.remove(key);
		}

		System.gc();
		trace ('check memory boi');
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}

	public static function returnSound(path:String, key:String, ?library:String) {
		#if desktop
		var file:String = modsSounds(path, key);
		if(FileSystem.exists(file)) {
			if(!currentTrackedSounds.exists(file)) {
				currentTrackedSounds.set(file, Sound.fromFile(file));
			}
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(file);
		}
		#end
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);	
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if(!currentTrackedSounds.exists(gottenPath)) 
		#if desktop
			currentTrackedSounds.set(gottenPath, Sound.fromFile('./' + gottenPath));
		#else
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		#end
		localTrackedAssets.push(key);
		return currentTrackedSounds.get(gottenPath);
	}

	public static function cacheImage(key:String, ?library:String = null)
	{
		var path:String;

		if (FileSystem.exists(modsImages(key)))
			path = modsImages(key);
		else if (FileSystem.exists(FileSystem.absolutePath('assets/shared/images/$key.png')))
			path = FileSystem.absolutePath('assets/shared/images/$key.png');
		else
			path = getPath('images/$key.png', IMAGE, library);
	
		if (FileSystem.exists(path) || Assets.exists(path)) 
		{
			if(!currentTrackedAssets.exists(key)) 
			{
				var newBitmap:BitmapData;

				if (FlxG.save.data.poltatoPC)
				{
					var matrix:Matrix = new Matrix();
					matrix.scale(0.5, 0.5);

					var bigBMP:BitmapData;

					if (Assets.exists(path))
						bigBMP = BitmapData.fromFile(path);
					else
						bigBMP = BitmapData.fromFile(path);

					newBitmap = new BitmapData(Std.int(bigBMP.width * 0.5), Std.int(bigBMP.height * 0.5), true, 0x000000);
					newBitmap.draw(bigBMP, matrix, null, null, null, true);

					bigBMP.dispose();
					bigBMP.disposeImage();
					bigBMP = null;
				}
				else	
					newBitmap = BitmapData.fromFile(path);

				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
				newGraphic.persist = true;
				currentTrackedAssets.set(key, newGraphic);
			}
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}

		trace('you failed dipshit');
		return null;		
	}
	public static function uncacheChars()
	{
		trace (charPath);
		
		for (i in 0... charPath.length)
			clearStoredMemory2('shared:assets/shared/images/'+ charPath[i]+ '.png');

		trace (charPath);
	}
	

	// currently not usin this
	public static function clearUnusedMemory2() 
	{
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) 
				&& !dumpExclusions.contains(key)) {
				// get rid of it
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null) {
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}
		// run the garbage collector for good measure lmfao
		System.gc(); //cuz this
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		#if MODS_ALLOWED
		if (!ignoreMods && FileSystem.exists(modFolders(key)))
			return File.getContent(modFolders(key));
		#end

		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function getTextureAtlas(key:String, ?library:String) //idk what to call this one
	{
		return FlxAtlasFrames.fromTexturePackerXml(image(key, library), file('images/$key.xml', library));
	}


	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{		
		#if desktop
		if(FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) {
			return true;
		}
		#end
		
		if(FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) {
			return true;
		}
		
		if(OpenFlAssets.exists(Paths.getPath(key, type))) {
			return true;
		}
		return false;
	}

	#if desktop
	inline static public function mods(key:String = '') {
		return 'mods/' + key;
	}
	
	inline static public function modsFont(key:String) {
		return modFolders('fonts/' + key);
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/' + key + '.json');
	}

	inline static public function modsVideo(key:String) {
		return modFolders('videos/' + key + '.mp4');
	}

	inline static public function modsSounds(path:String, key:String) {
		return modFolders(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsImages(key:String) {
		return modFolders('images/' + key + '.png');
	}

	inline static public function modsXml(key:String) {
		return modFolders('images/' + key + '.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/' + key + '.txt');
	}

	inline static public function modsAchievements(key:String) {
		return modFolders('achievements/' + key + '.json');
	}

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = mods(currentModDirectory + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}
		return 'mods/' + key;
	}

	static public function getModDirectories():Array<String> {
		var list:Array<String> = [];
		var modsFolder:String = Paths.mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.contains(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}
	#end
}
