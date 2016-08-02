import gab.opencv.*;
import java.util.*;

OpenCV cv1, cv2, cv3, cv4;
Histogram grayHist1, grayHist2, grayHist3, grayHist4;

PImage img1, img2, img3, img4, th1, th2, th3, th4;
int [] hist1 = new int [256];
int [] hist2 = new int [256];
int [] hist3 = new int [256];
int [] hist4 = new int [256];
int p = 70;

void setup() {
  size(1000, 800);
  noLoop();
  //画像の入力
  img1 = loadImage("sample1.png");
  img2 = loadImage("sample2.png");
  img3 = loadImage("sample3.png");
  img4 = loadImage("hane.png");
  //openCV用のクラスのコンストラクタ呼び出し
  cv1 = new OpenCV(this, img1);
  cv2 = new OpenCV(this, img2);
  cv3 = new OpenCV(this, img3);
  cv4 = new OpenCV(this, img4);

  //histogram生成
  grayHist1 = cv1.findHistogram(cv1.getGray(), 256);
  grayHist2 = cv2.findHistogram(cv2.getGray(), 256);
  grayHist3 = cv3.findHistogram(cv3.getGray(), 256);
  grayHist4 = cv4.findHistogram(cv4.getGray(), 256);

  img4 = cv4.getSnapshot(cv4.getGray());  //グレースケールに変換

  //各画像のピクセルデータを抽出
  img1.loadPixels();
  img2.loadPixels();
  img3.loadPixels();
  img4.loadPixels();

  for (int i = 0; i<hist1.length; i++) hist1[i]=0;
  for (int i = 0; i<hist2.length; i++) hist2[i]=0;
  for (int i = 0; i<hist3.length; i++) hist3[i]=0;
  for (int i = 0; i<hist4.length; i++) hist4[i]=0;


  //println(grayHist1.getMat().dump());


  /* //各ピクセルの輝度値を抽出 for debag
   for (int y=0; y< img3.height; y++) {
   for (int x=0; x< img3.width; x++)
   println((int)brightness(img3.pixels[y*img3.width+x]));
   }*/

  //histogram配列の生成

  for (int y=0; y< img1.height; y++) {
    for (int x=0; x< img1.width; x++)
      hist1[(int)brightness(img1.pixels[y*img1.width+x])] ++;
  }

  for (int y=0; y< img2.height; y++) {
    for (int x=0; x< img2.width; x++)
      hist2[(int)brightness(img2.pixels[y*img2.width+x])] ++;
  }

  for (int y=0; y< img3.height; y++) {
    for (int x=0; x< img3.width; x++)
      hist3[(int)brightness(img3.pixels[y*img3.width+x])] ++;
  }

  for (int y=0; y< img4.height; y++) {
    for (int x=0; x< img4.width; x++)
      hist4[(int)brightness(img4.pixels[y*img4.width+x])] ++;
  }

  cv1.threshold(pTile(hist1, p, img1.width, img1.height));
  th1=cv1.getOutput();
  cv2.threshold(pTile(hist2, p, img2.width, img2.height));
  th2=cv2.getOutput();
  cv3.threshold(pTile(hist3, p, img3.width, img3.height));
  th3=cv3.getOutput();
  cv4.threshold(pTile(hist4, p, img4.width, img4.height));
  th4=cv4.getOutput();

  /*
  //for debug
   for (int y=0; y< th3.height; y++) {
   for (int x=0; x< th3.width; x++)
   print(brightness(th3.pixels[y*th3.width+x]) + ",");
   println();
   }
   */

  //println(pTile(hist3, p, img3.width, img3.height));
  //println("renketsu1 " + labelNum2(th1));
  //println("renketsu2 " + labelNum2(th2));
  //println("renketsu3 " + labelNum2(th3));
  println("new1 " + labeling(th1));
  println("new2 " + labeling(th2));
  println("new3 " + labeling(th3));
}

//Pタイル法で閾値を求めるための関数
//引数 hist:ヒストグラム p:閾値を決定する際の割合 w,h:画像のサイズ
int pTile(int[] hist, int p, int w, int h) {
  int t, tmp = 0;

  t = (int)(w * h * p /100.0);
  for (int i = 0; i < 256; i++) {
    tmp += hist[i];
    if (tmp>=t) return i;
  }
  return 0;
}


int matrixSize = 3;

int labeling(PImage in) {
  /* 未調査座標を格納するリスト */
  ArrayList<Integer> underExamCoordinate = new ArrayList<Integer>();
  int labelNumber = 0;
  int index = 0;
  int ux, uy;
  in.loadPixels();
  int w = in.width;
  int h = in.height;
  int[] label = new int[w*h];

  for (int y=0; y<h; y++) {
    for (int x=0; x<w; x++) {
      /* まだラベルが貼られていないなら */
      if (label[y*w+x] == 0) {
        /* 次のラベルへ移行 */
        labelNumber++;
        label[y*w+x] = labelNumber;
        /* 最初の未調査座標を追加 */
        underExamCoordinate.add(y*w+x);

        do {
          index = 0;
          uy = (int)Math.floor(Integer.valueOf(underExamCoordinate.get(0).toString()) / w);
          ux = Integer.valueOf(underExamCoordinate.get(0).toString()) - (uy * w);

          for (int he=uy- (matrixSize/2); he<=uy+(matrixSize/2); he++) {
            for (int wi=ux- (matrixSize/2); wi<=ux+(matrixSize/2); wi++) {
              if (he < 0 || h <= he || wi < 0 || w<= wi) {
              } else {
                /* 未調査座標の上下左右のいずれかの座標なら */
                if (index % 2 == 1) {
                  /* 既にラベルが貼られているかどうか */
                  if (label[he*w+wi] == 0) {
                    if (in.pixels[he*w+wi] == in.pixels[y*w+x]) {
                      label[he*w+wi] = labelNumber;
                      underExamCoordinate.add(he*w+wi);
                      //println("meu");
                    }
                  }
                }
              }
              index++;
            }
          }
          underExamCoordinate.remove(0);
        }
        while (underExamCoordinate.size () > 0);
        underExamCoordinate.clear();
      }
    }
  }
  return labelNumber;
}


void draw() {
  background(100, 200, 100);

  //元画像を表示
  image(img1, 10, 0, img1.width/4, img1.height/4);
  image(img2, 10, img1.height/4 + 10);
  image(img3, 10, img1.height/4 + img2.height + 20);
  image(img4, 10, img1.height/4 + img2.height + img3.height + 30, img4.width/5, img4.height/5);

  //2値化画像を表示
  image(th1, 700, 0, img1.width/4, img1.height/4);
  image(th2, 700, img1.height/4 + 10);
  image(th3, 700, img1.height/4 + img2.height + 20);
  image(th4, 700, img1.height/4 + img2.height + img3.height + 30, img4.width/5, img4.height/5);
  textSize(16);
  text(labeling(th1),960,100);
  text(labeling(th2),960,300);
  text(labeling(th3),960,600);

  //histogramの外枠
  for (int i = 0; i < 4; i++) {
    stroke(125); 
    noFill();  
    rect(320, 10+i*200, 310, 180);
  }

  //histogram本体
  fill(125); 
  noStroke();
  grayHist1.draw(320, 10, 310, 180);
  grayHist2.draw(320, 210, 310, 180);
  grayHist3.draw(320, 410, 310, 180);
  grayHist4.draw(320, 610, 310, 180);
}

