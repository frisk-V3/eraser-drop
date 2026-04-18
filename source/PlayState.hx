package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var playerEraser:FlxSprite;
	private var enemyEraser:FlxSprite;
	private var table:FlxSprite;
	private var wall:FlxSprite;
	private var dragLine:FlxSprite;
	private var isDragging:Bool = false;
	private var dragStart:FlxPoint;
	private var gameOver:Bool = false;
	private var gameOverText:FlxText;
	private var isPlayerTurn:Bool = true;
	private var turnTimer:Float = 0;
	private var turnText:FlxText;
	private var enemyMoved:Bool = false;
	private var mode:String;
	private var wins:Int = 0;
	private var losses:Int = 0;
	private var totalGames:Int = 0;
	private var hitStopTimer:Float = 0;
	private var enemyDrag:Float = 200;

	public function new(mode:String = "cpu")
	{
		this.mode = mode;
		super();
	}

	override public function create()
	{
		super.create();

		// 机の作成 (画面中央の大きな矩形)
		table = new FlxSprite((FlxG.width - 400) / 2, (FlxG.height - 300) / 2);
		table.makeGraphic(400, 300, FlxColor.BROWN);
		table.immovable = true; // 机は動かない
		add(table);

		// プレイヤーの消しゴム (青色)
		playerEraser = new FlxSprite(table.x + 50, table.y + table.height / 2 - 10);
		playerEraser.makeGraphic(20, 20, FlxColor.BLUE);
		playerEraser.drag.set(200, 200); // 減衰で徐々に停止
		add(playerEraser);

		// 敵の消しゴム (赤色)
		enemyEraser = new FlxSprite(table.x + table.width - 70, table.y + table.height / 2 - 10);
		enemyEraser.makeGraphic(20, 20, FlxColor.RED);
		enemyEraser.drag.set(enemyDrag, enemyDrag);
		add(enemyEraser);

		// 壁ギミック (机の中央)
		wall = new FlxSprite(table.x + table.width / 2 - 10, table.y + table.height / 2 - 10);
		wall.makeGraphic(20, 20, FlxColor.GRAY);
		wall.immovable = true;
		add(wall);

		// ドラッグライン (透明なスプライトでラインを描画)
		dragLine = new FlxSprite();
		dragLine.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		add(dragLine);

		// ゲームオーバーテキスト
		gameOverText = new FlxText(0, FlxG.height / 2 - 50, FlxG.width, "Game Over! Press R to Restart", 32);
		gameOverText.alignment = CENTER;
		gameOverText.color = FlxColor.RED;
		gameOverText.visible = false;
		add(gameOverText);

		// ターン表示テキスト
		turnText = new FlxText(10, 10, 0, "Your Turn", 24);
		turnText.color = FlxColor.WHITE;
		add(turnText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (gameOver)
		{
			if (FlxG.keys.justPressed.R)
			{
				FlxG.resetState();
			}
			return;
		}

		// ターン表示更新
		turnText.text = isPlayerTurn ? "Your Turn" : "Enemy Turn";

		if (isPlayerTurn)
		{
			if (mode == "100matches")
			{
				// 自動プレイヤー
				var angle = FlxG.random.float(0, 2 * Math.PI);
				playerEraser.velocity.set(Math.cos(angle) * 100, Math.sin(angle) * 100);
				isPlayerTurn = false;
				turnTimer = 2.0;
				enemyMoved = false;
				enemyEraser.drag.set(0, 0);
			}
			else
			{
				// 手動操作
				if (FlxG.mouse.justPressed && playerEraser.overlapsPoint(FlxG.mouse.getWorldPosition()))
				{
					isDragging = true;
					dragStart = FlxG.mouse.getWorldPosition();
				}

				if (isDragging)
				{
					var currentMouse = FlxG.mouse.getWorldPosition();
					// ラインを描画 (シンプルに長方形で表現)
					var dx = currentMouse.x - playerEraser.x;
					var dy = currentMouse.y - playerEraser.y;
					var length = Math.sqrt(dx * dx + dy * dy);
					dragLine.makeGraphic(Math.floor(length), 2, FlxColor.YELLOW);
					dragLine.x = playerEraser.x;
					dragLine.y = playerEraser.y;
					dragLine.angle = Math.atan2(dy, dx) * 180 / Math.PI;

					if (FlxG.mouse.justReleased)
					{
						isDragging = false;
						// 引っ張った方向の反対に飛ばす
						var pullVector = new FlxPoint(dragStart.x - currentMouse.x, dragStart.y - currentMouse.y);
						var boost = Math.min(pullVector.length / 100, 1.5); // 物理ブースト
						playerEraser.velocity.set(pullVector.x * 2 * boost, pullVector.y * 2 * boost); // 力の調整
						dragLine.makeGraphic(1, 1, FlxColor.TRANSPARENT);
						// ターン切り替え
						isPlayerTurn = false;
						turnTimer = 2.0;
						enemyMoved = false;
						enemyEraser.drag.set(0, 0);
					}
				}
			}
		}
		else
		{
			// 敵のAI: ターン開始時に一度だけ方向決定
			if (!enemyMoved)
			{
				var dx = playerEraser.x - enemyEraser.x;
				var dy = playerEraser.y - enemyEraser.y;
				var distance = Math.sqrt(dx * dx + dy * dy);
				if (distance > 0)
				{
					enemyEraser.velocity.set((dx / distance) * 100, (dy / distance) * 100); // 一度の強い移動
				}
				enemyMoved = true;
			}

			// ターンタイマー
			turnTimer -= elapsed;
			if (turnTimer <= 0)
			{
				isPlayerTurn = true;
				enemyMoved = false;
				enemyEraser.drag.set(enemyDrag, enemyDrag);
			}
		}

		// 衝突判定
		var collided = FlxG.collide(playerEraser, enemyEraser);
		FlxG.collide(playerEraser, table);
		FlxG.collide(playerEraser, wall);
		FlxG.collide(enemyEraser, table);
		FlxG.collide(enemyEraser, wall);

		// ヒットストップとカメラシェイク
		if (collided)
		{
			shakeCamera();
		}

		// 勝敗判定
		if (!table.overlaps(playerEraser))
		{
			gameOver = true;
			if (mode == "100matches")
			{
				losses++;
				totalGames++;
				if (totalGames >= 100)
				{
					gameOverText.text = "100 Matches Finished! Wins: " + wins + " Losses: " + losses;
				}
				else
				{
					resetGame();
				}
			}
			else
			{
				gameOverText.text = "You Lose! Press R to Restart";
				gameOverText.visible = true;
			}
		}
		else if (!table.overlaps(enemyEraser))
		{
			gameOver = true;
			if (mode == "100matches")
			{
				wins++;
				enemyDrag += 10; // 難易度アップ
				totalGames++;
				if (totalGames >= 100)
				{
					gameOverText.text = "100 Matches Finished! Wins: " + wins + " Losses: " + losses;
				}
				else
				{
					resetGame();
				}
			}
			else
			{
				wins++;
				enemyDrag += 10; // 難易度アップ
				gameOverText.text = "You Win! Press R to Restart";
				gameOverText.color = FlxColor.GREEN;
				gameOverText.visible = true;
			}
		}
	}

	private function resetGame()
	{
		// 位置リセット
		playerEraser.x = table.x + 50;
		playerEraser.y = table.y + table.height / 2 - 10;
		playerEraser.velocity.set(0, 0);
		enemyEraser.x = table.x + table.width - 70;
		enemyEraser.y = table.y + table.height / 2 - 10;
		enemyEraser.velocity.set(0, 0);
		enemyEraser.drag.set(enemyDrag, enemyDrag);
		isPlayerTurn = true;
		turnTimer = 0;
		enemyMoved = false;
		gameOver = false;
		gameOverText.visible = false;
	}

	private function shakeCamera()
	{
		FlxG.camera.shake(0.01, 0.1);
	}
}
