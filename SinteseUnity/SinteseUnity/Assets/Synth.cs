using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Synth : MonoBehaviour {

    public Texture2D targ, samp;
    public int adj = 1;
    public Image img;

	// Use this for initialization
	void Start () {

        CreateTexture(Instantiate(targ));
	}
	
	// Update is called once per frame
	public void CreateTexture(Texture2D imTarget) {
        Color[] pixels;

        Vector2Int distPixel = Vector2Int.zero;
        Texture2D img2 = imTarget;


        for (int j = 0; j < targ.height; j++)
        {
            for (int i = 0; i < targ.width; i++)
            {
                pixels = Adjency(targ, adj, i, j); // Pixels adjacentes
                float mDist = Mathf.Infinity;

                for (int jj = 0; jj < samp.height; jj++)
                {
                    for (int ii = 0; ii < samp.width; ii++)
                    {
                        Color[] aPixels = Adjency(samp, adj, ii, jj);
                        float difference = 0;

                        for (int k = 0; k < aPixels.Length; k++)
                        {
                            difference += ColorDistance(pixels[k].r, pixels[k].g, pixels[k].b, aPixels[k].r, aPixels[k].g, aPixels[k].b);
                        }

                        if (mDist >= difference)
                        {
                            distPixel = new Vector2Int(ii, jj);
                            mDist = difference;
                        }
                    }
                }

                img2.SetPixel(i, j, samp.GetPixel(distPixel.x, distPixel.y));
            }
        }
        img2.Apply();
        img.sprite = Sprite.Create(img2, new Rect(0, 0, img2.width, img2.height), Vector2.zero);
    }

    public Color[] Adjency(Texture2D image, int adj, int hor, int ver)
    {
        List<Color> arrColor = new List<Color>();

        for (int i = -adj; i <= adj; i++)
        {
            for (int j = -adj; j <= adj; j++)
            {
                if (i != 0 && j != 0)
                {
                    int aX = hor + j;
                    int aY = ver + i;

                    if (aX < 0)
                    {
                        aX = image.width - 1;
                    }
                    else if (aX >= image.width)
                    {
                        aX = 0;
                    }

                    if (aY == -1)
                    {
                        aY = image.height - 1;
                    }
                    else if (aY == image.height)
                    {
                        aY = 0;
                    }

                    arrColor.Add(image.GetPixel(aX, aY));
                }
            }
        }

        return arrColor.ToArray();
    }

    public float ColorDistance(float r, float g, float b, float ar, float ag, float ab)
    {
        float distance = ((r - ar) * (r - ar)) + ((g - ag) * (g - ag)) + ((b - ab) * (b - ab));
        return Mathf.Sqrt(distance);
    }
}
