package states;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import gameObjects.Bullet;
import gameObjects.MeleeHitbox;
import gameObjects.enemies.PistolEnemy;
import gameObjects.enemies.Enemy;
import gameObjects.enemies.ShotgunEnemy;
import gameObjects.enemies.Zombie;
import gameObjects.freeWeapons.FreeGun;
import gameObjects.freeWeapons.FreeShotgun;
import gameObjects.freeWeapons.FreeWeapon;
import gameObjects.weapons.Gun;
import gameObjects.Mirko;
import gameObjects.Vodka;
import gameObjects.weapons.Shotgun;
import gameObjects.weapons.Weapon;
import gameObjects.weapons.ZombieGrab;
import openfl.Assets;

class GameState extends FlxState
{

	var mMapBack:FlxTilemap;
	var mMapWalls:FlxTilemap;
	var mMapFloor:FlxTilemap;
	var mMapObj:FlxTilemap;
	var mMapSmallObj:FlxTilemap;
	var mirko:Mirko;
	var weapon:Weapon;
	var bullets:FlxGroup;
	var enemyBullets:FlxGroup;
	var enemies:FlxGroup;
	var freeWeapons:FlxGroup;
	var enemiesHitboxes:FlxGroup;
	var score:Int;
	var scoreLabel:FlxText;
	var hpLabel:FlxText;
	var time:Float;
	var gameOver:FlxText;
	var restartButton:FlxButton;
	var killesToVodka:Int;
	var vodkas:FlxGroup;
	var enemyEntryPoints:Array<FlxPoint>;
	var pathGenerator:PathGenerator;

	public function new() 
	{
		super();
		
		
	}
	override public function create():Void 
	{
		mMapBack = new FlxTilemap();
		mMapBack.loadMapFromCSV(Assets.getText("map/BigMap_Background.csv"), Assets.getBitmapData("img/tilesheet_complete.png"), 64, 64,null,0,0);
		add(mMapBack);
		
		mMapFloor = new FlxTilemap();
		mMapBack.loadMapFromCSV(Assets.getText("map/BigMap_Floor.csv"), Assets.getBitmapData("img/tilesheet_complete.png"), 64, 64,null,0,0);
		add(mMapFloor);
		
		mMapWalls = new FlxTilemap();
		mMapWalls.loadMapFromCSV(Assets.getText("map/BigMap_Walls.csv"), Assets.getBitmapData("img/tilesheet_complete.png"), 64, 64,null,0,1);
		add(mMapWalls);
		
		mMapObj = new FlxTilemap();
		mMapBack.loadMapFromCSV(Assets.getText("map/BigMap_Objects.csv"), Assets.getBitmapData("img/tilesheet_complete.png"), 64, 64,null,0,0);
		add(mMapObj);
		
		mMapSmallObj = new FlxTilemap();
		mMapBack.loadMapFromCSV(Assets.getText("map/BigMap_Small Objects.csv"), Assets.getBitmapData("img/tilesheet_complete.png"), 64, 64,null,0,0);
		add(mMapSmallObj);
		
		vodkas = new FlxGroup();
		add(vodkas);
		bullets = new FlxGroup();
		add(bullets);
		enemyBullets = new FlxGroup();
		add(enemyBullets);
		enemiesHitboxes = new FlxGroup();
		add(enemiesHitboxes);

		weapon = new Gun(bullets);

		mirko = new Mirko(100, 100, weapon);
		add(mirko);
		
		GlobalGameData.instance.setPlayer(mirko);
		
		enemies = new FlxGroup();
		add(enemies);
		
		freeWeapons = new FlxGroup();
		add(freeWeapons);
		
		var freeWeapon:FreeWeapon = new FreeGun(200, 200);
		freeWeapons.add(freeWeapon);
		
		var freeWeapon2:FreeWeapon = new FreeShotgun(300, 200);
		freeWeapons.add(freeWeapon2);
		
		score = 0;
		scoreLabel = new FlxText(FlxG.camera.x + 20, FlxG.camera.y + 20, 130, "Score: 0", 12);
		hpLabel = new FlxText(FlxG.camera.x + 35, FlxG.camera.y + 35, 130, "HP: 10", 12);
		
		add(scoreLabel);
		add(hpLabel);
		
		time = 0;
		
		FlxG.camera.follow(mirko, FlxCameraFollowStyle.TOPDOWN);
		FlxG.camera.setScrollBoundsRect(0, 0, mMapBack.width, mMapBack.height);
		FlxG.worldBounds.set(0, 0, mMapBack.width, mMapBack.height);
		
		pathGenerator = new PathGenerator();
		
		//createGunEnemy();
		
		//createShotgunEnemy();
		
		createZombieEnemy();

		
		enemyEntryPoints = setEnemiesEntryPoints();
		
		killesToVodka = 5;
		
		//FlxG.sound.play(Assets.getText("sound/war_go_go_go.ogg"));
		

		
		
	}
	override public function update(aDelta:Float):Void 
	{
		super.update(aDelta);
		time += aDelta;
		if (time >= 2){
			
			var aGun:Weapon = new Gun(enemyBullets);
			var point = enemyEntryPoints[FlxG.random.int(0, 3)];
			var enemy:Enemy = new PistolEnemy(point.x, point.y, aGun, mMapWalls, pathGenerator.demoPath());
			//enemies.add(enemy);
			//add(enemy);
			time = 0;
		}
		
		

		FlxG.collide(mirko, mMapWalls);
		FlxG.collide(enemies, mMapWalls);
		FlxG.collide(mirko, mMapObj);
		FlxG.collide(mirko, mMapSmallObj);
		FlxG.collide(enemies, mMapObj);
		FlxG.collide(enemies, mMapSmallObj);

		FlxG.collide(mMapWalls, bullets, wallsVsBullets);
		FlxG.collide(mMapWalls, enemyBullets, wallsVsBullets);
		FlxG.collide(mMapObj, bullets, wallsVsBullets);
		FlxG.collide(mMapObj, enemyBullets, wallsVsBullets);
		FlxG.collide(mMapSmallObj, bullets, wallsVsBullets);
		FlxG.collide(mMapSmallObj, enemyBullets, wallsVsBullets); 
		
		
		FlxG.overlap(bullets, enemies, bulletVsEnemies);
		FlxG.overlap(enemyBullets, mirko, bulletVsMirko);
		FlxG.overlap(mirko, vodkas, mirkoVsVodka);
		FlxG.overlap(mirko, freeWeapons, mirkoVsFreeWeapon);
		FlxG.overlap(enemiesHitboxes, mirko, meleeVsMirko);
		
		score = GlobalGameData.instance.getScore();
		scoreLabel.x = mirko.x;
		scoreLabel.y = mirko.y - 30;
		scoreLabel.text = "Score: " + cast score;
		hpLabel.x = mirko.x;
		hpLabel.y = mirko.y - 50;
		hpLabel.text = "HP: " + cast mirko.get_HP();
	}
	
	private function wallsVsBullets(walls:FlxTilemap,aBullet:Bullet):Void
	{
		aBullet.kill();
		//FlxG.sound.play(Assets.getText("sound/war_go_go_go.ogg"));
	}
	
	private function bulletVsEnemies(aBullet:Bullet,aEnemy:Enemy):Void
	{
		aBullet.kill();
		aEnemy.damage();
		
		killesToVodka -= 1;
		if (killesToVodka == 0){
			killesToVodka = 5;
			var xPoints = FlxG.random.int(0, 1280);
			var yPoints = FlxG.random.int(0, 720);
			if (mMapWalls.getTile(Std.int(xPoints / 64), Std.int(yPoints / 64)) != -1 )
			{
				xPoints += 64;
				yPoints += 64;
			}
			var vodka = new Vodka(xPoints, yPoints);
			vodkas.add(vodka);
		}
		
	}
	
	private function bulletVsMirko(aBullet:Bullet, aMirko:Mirko):Void
	{
		aBullet.kill();
		damageMirko(aMirko, 1);
	}
	
	private function meleeVsMirko(hitbox:MeleeHitbox, aMirko:Mirko):Void
	{
		hitbox.kill();
		damageMirko(aMirko, 5);
	}
	
	public function damageMirko(aMirko:Mirko, damage:Int)
	{
		
		if (aMirko.get_HP() > damage)
		{
			aMirko.removeHP(damage);
			
		}else
		{
			hpLabel.text = "HP: " + cast 0;
			aMirko.kill();
			gameOver = new FlxText(mirko.x, mirko.y, 500, "GameOver", 20);
			add(gameOver);
			restartButton = new FlxButton(350 , 300, "Restart", restartGame);
			//restartButton.parallax.set(0);
			restartButton.scrollFactor.set(0,0);
			add(restartButton);
		}
	}
	
	private function mirkoVsVodka(aMirko:Mirko, aVodka:Vodka):Void
	{
		aVodka.kill();
		var health:Int = mirko.get_HP();
		health++;
		mirko.setHp(health);
		hpLabel.text = "HP: " + cast health;
		
	}
	
	private function mirkoVsFreeWeapon(aMirko:Mirko, freeWeapon:FreeWeapon):Void
	{
		var type = freeWeapon.getWeapon();
		freeWeapon.kill();
		switch type {
			case "gun":
				var newWeapon:Weapon = new Gun(bullets);
				mirko.setWeapon(newWeapon);
			case "shotgun":
				var newWeapon:Weapon = new Shotgun(bullets);
				mirko.setWeapon(newWeapon);
			default: 
				var newWeapon:Weapon = new Gun(bullets);
				mirko.setWeapon(newWeapon);
		}
	}
	
	private function restartGame():Void		
	{
		GlobalGameData.instance.setScore(0);
		FlxG.resetState();

	}
	
	private function setEnemiesEntryPoints():Array<FlxPoint>
	{
		var points = new Array<FlxPoint>();
		
		var point1 = new FlxPoint( -10, -10);
		var point2 = new FlxPoint( -10, mMapBack.height + 10);
		var point3 = new FlxPoint( mMapBack.width + 10, -10);
		var point4 = new FlxPoint(mMapBack.height + 10, mMapBack.width + 10);
		
		points.push(point1);
		points.push(point2);
		points.push(point3);
		points.push(point4);
		
		return points;
	}
	
	private function createGunEnemy(){
		var aGun:Weapon = new Gun(enemyBullets);
		var enemy:Enemy = new PistolEnemy(64 * 5 + 32, 64 * 6 + 32, aGun, mMapWalls, pathGenerator.demoPath());
		enemies.add(enemy);
		add(enemy);
	}
	
	private function createZombieEnemy(){
		var grab:Weapon = new ZombieGrab(enemiesHitboxes);
		var zombie:Enemy = new Zombie(64 * 5 + 32, 64 * 8 + 32, grab, mMapWalls, pathGenerator.demoPath());
		enemies.add(zombie);
		add(zombie);
	}
	
	private function createShotgunEnemy()
	{
		var shotgun:Weapon = new Shotgun(enemyBullets);
		var shotgunEnemy:Enemy = new ShotgunEnemy(64 * 5 + 32, 64 * 8 + 32, shotgun, mMapWalls, pathGenerator.demoPath());
		enemies.add(shotgunEnemy);
		add(shotgunEnemy);
	}
	
	
	
}
