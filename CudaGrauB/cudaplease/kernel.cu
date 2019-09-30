
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <list>
#include <stdio.h>
using namespace std;

int* sample;
int sampleW;
int sampleH;
int* sampleR;
int* sampleG;
int* sampleB;

int* target;
int targetW;
int targetH;
int* targetR;
int* targetG;
int* targetB;

int* resultR;
int* resultG;
int* resultB;

int sizeAdj = 1;

__global__ void addKernel(int* imgW, int* imgH, float* distances, int* sampleR, int* sampleG, int* sampleB, int* targetR, int* targetG, int* targetB, int* adjSize)
{
	printf("Entered the Kernel");
	float dist = 0;
	int adj = 0;
	for (int i = -*adjSize; i <= *adjSize; i++)
	{
		for (int j = -*adjSize; j <= *adjSize; j++, adj++)
		{
			if (i != 0 && j != 0)
			{
				int aX = *imgW + j;
				int aY = *imgH + i;

				if (aX < 0)
				{
					aX = *imgW - 1;
				}
				else if (aX >= *imgW)
				{
					aX = 0;
				}

				if (aY == -1)
				{
					aY = *imgH - 1;
				}
				else if (aY == *imgH)
				{
					aY = 0;
				}
				int r = sampleR[aY * blockDim.x + aX] - targetR[adj];
				int g = sampleG[aY * blockDim.x + aX] - targetG[adj];
				int b = sampleB[aY * blockDim.x + aX] - targetB[adj];
				dist += sqrtf(r*r + g*g + b*b);

			}
		}
	}

	distances[blockIdx.x * blockDim.x + threadIdx.x] = dist;
}


vector<int> GetPixelsSample(int sizeAdj, int sizeW, int sizeH)
{
	vector<int> pixelsArr;
	for (int i = -sizeAdj; i <= sizeAdj; i++)
	{
		for (int j = -sizeAdj; j <= sizeAdj; j++)
		{
			if (i != 0 && j != 0)
			{
				int aX = sizeW + j;
				int aY = sizeH + i;

				if (aX < 0)
				{
					aX = sampleW - 1;
				}
				else if (aX >= sampleW)
				{
					aX = 0;
				}

				if (aY == -1)
				{
					aY = sampleH - 1;
				}
				else if (aY == sampleH)
				{
					aY = 0;
				}
				pixelsArr.push_back(sample[aY * sampleW + aX]);
			}
		}
	}
	
	return pixelsArr;
}

vector<int> GetPixelsTarget(int sizeAdj, int sizeW, int sizeH)
{
	vector<int> pixelsArr;
	for (int i = -sizeAdj; i <= sizeAdj; i++)
	{
		for (int j = -sizeAdj; j <= sizeAdj; j++)
		{
			if (i != 0 && j != 0)
			{
				int aX = sizeW + j;
				int aY = sizeH + i;

				if (aX < 0)
				{
					aX = targetW - 1;
				}
				else if (aX >= targetW)
				{
					aX = 0;
				}

				if (aY == -1)
				{
					aY = targetH - 1;
				}
				else if (aY == targetH)
				{
					aY = 0;
				}
				pixelsArr.push_back(target[aY * targetW + aX]);
			}
		}
	}

	return pixelsArr;
}

void ReadFile(string sample_, string target_)
{

	ifstream file1, file2;

	string s, t;

	file1.open(sample_);
	cout << "==Reading the sample file (1/6) - Process 1 out of xx ==" << endl;
	if (!file1)
	{
		return;
	}
	cout << "==Read the sample file (2/6) - Process 1 out of x ==" << endl;

	file1 >> s;
	char buffer[1000];
	bool invalid = true;
	do
	{
		file1 >> s;
		if (s == "#")
		{
			file1.getline(buffer, 100);
		}
		else
		{
			invalid = false;
		}
	} while (invalid);

	sampleW = atoi(s.c_str());
	file1 >> sampleH >> s;

	int sampleArrSize = sampleW * sampleH;
	sample = new int[sampleArrSize];
	sampleR = new int[sampleArrSize];
	sampleG = new int[sampleArrSize];
	sampleB = new int[sampleArrSize];

	for (int j = 0; j < sampleH; j++)
	{
		for (int i = 0; i < sampleW; i++)
		{
			file1 >> s;
			sampleR[j * sampleW + i] = stoi(s);
			file1 >> s;
			sampleG[j * sampleW + i] = stoi(s);
			file1 >> s;
			sampleB[j * sampleW + i] = stoi(s);
		}
	}
	file1.close();

	cout << "==Finished with the sample file (3/6) - Process 1 out of x ==" << endl;

	file2.open(target_);
	cout << "==Reading the texture file (4/6) - Process 1 out of x ==" << endl;
	if (!file2)
	{
		cout << "==ERROR: COULDNT READ TEXTURE==" << endl;
		return;
	}
	cout << "==Read the target file (5/6) - Process 1 out of x ==" << endl;

	file2 >> t;

	invalid = true;
	do
	{
		file2 >> t;
		if (t == "#")
		{
			file2.getline(buffer, 100);
		}
		else
		{
			invalid = false;
		}
	} while (invalid);


	targetW = atoi(t.c_str());
	file2 >> targetH >> t;

	int targetArrSize = targetW * targetH;
	target = new int[targetArrSize];
	targetR = new int[targetArrSize];
	targetG = new int[targetArrSize];
	targetB = new int[targetArrSize];

	for (int j = 0; j < targetH; j++)
	{
		for (int i = 0; i < targetW; i++)
		{
			file2 >> t;
			targetR[j * targetW + i] = stoi(t);
			file2 >> t;
			targetG[j * targetW + i] = stoi(t);
			file2 >> t;
			targetB[j * targetW + i] = stoi(t);
		}
	}
	file2.close();

	cout << "==Finished with the target file (6/6) - Process 1 out of sdwqedq ==" << endl;
	return;
}

void WriteFile(string filename)
{
	cout << "Entered the file writing function!" << endl;
	ofstream resultfile;

	resultfile.open(filename);

	resultfile << "P3" << endl << "# Criado para cadeira de Arquiteturas Gráficas, por João Rothmann" << endl << targetW << " " << targetH << endl << "255" << endl;

	for (int j = 0; j < targetH; j++)
	{
		for (int i = 0; i < targetW; i++)
		{
			int pos = j * targetW + i;
			resultfile << resultR[pos] << " " << resultG[pos] << " " << resultB[pos] << " " << endl;
		}
	}

	cout << "targetW: " << targetW << endl;
	cout << "targetH: " << targetH << endl;
	cout << "sampleW: " << targetW << endl;
	cout << "sampleH: " << targetH << endl;
	resultfile.close();
}

float CalculateDistance(int tr, int tg, int tb, int sr, int sg, int sb)
{
	float distance = float(((tr - sr) * (tr - sr)) + ((tg - sg) * (tg - sg)) + ((tb - sb) * (tb - sb)));
	return powf(distance, 0.5f);
}




// Helper function for using CUDA to add vectors in parallel.
cudaError_t addWithCuda(int* imgW_, int* imgH_, int* targetW_, int* targetH_, float* distances_, int* sampleR_, int* sampleG_, int* sampleB_, int* targetR_, int* targetG_, int* targetB_, int* adjSize_)
{
	printf("Entered Cuda\n");
	int* imgW = 0;
	int* imgH = 0;
	int* targetW = 0;
	int* targetH = 0;
	float* distances = 0;
	int* sampleR = 0;
	int* sampleG = 0;
	int* sampleB = 0;
	int* targetR = 0;
	int* targetG = 0;
	int* targetB = 0;
	int* adjSize = 0;
    cudaError_t cudaStatus;

    // Choose which GPU to run on, change this on a multi-GPU system.
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        goto Error;
    }

    // Allocate GPU buffers for three vectors (two input, one output)    .
    cudaStatus = cudaMalloc((void**)&imgW, sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&imgH, sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

	cudaStatus = cudaMalloc((void**)&targetW, sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}

	cudaStatus = cudaMalloc((void**)&targetH, sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}
	cudaStatus = cudaMalloc((void**)&distances, *imgW_ * *imgH_ * sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}
	cudaStatus = cudaMalloc((void**)&sampleR, *imgW_ * *imgH_ * sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}
	cudaStatus = cudaMalloc((void**)&sampleG, *imgW_ * *imgH_ * sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}
	cudaStatus = cudaMalloc((void**)&sampleB, *imgW_ * *imgH_ * sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}
	cudaStatus = cudaMalloc((void**)&targetR, *targetW_ * *targetH_ * sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}
	cudaStatus = cudaMalloc((void**)&targetG, *targetW_ * *targetH_ * sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}
	cudaStatus = cudaMalloc((void**)&targetB,  *targetW_ * *targetH_ * sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}
	cudaStatus = cudaMalloc((void**)&adjSize, sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}

    // Copy input vectors from host memory to GPU buffers.
	cudaStatus = cudaMemcpy(imgW, imgW_, sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	cudaStatus = cudaMemcpy(imgH, imgH_, sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}   
	cudaStatus = cudaMemcpy(targetW, targetW_, sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	cudaStatus = cudaMemcpy(targetH, targetH_, sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}   
	cudaStatus = cudaMemcpy(distances, distances_, *imgW_ * *imgH_ * sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	cudaStatus = cudaMemcpy(sampleR, sampleR_, *imgW_ * *imgH_ * sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}  
	cudaStatus = cudaMemcpy(sampleG, sampleG_, *imgW_ * *imgH_ * sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	cudaStatus = cudaMemcpy(sampleB, sampleB_, *imgW_ * *imgH_ * sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}   
	
	cudaStatus = cudaMemcpy(targetR, targetR_, *targetW_ * *targetH_ * sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}
	cudaStatus = cudaMemcpy(targetG, targetG_, *targetW_ * *targetH_ * sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}  
	cudaStatus = cudaMemcpy(targetB, targetB_, *targetW_ * *targetH_ * sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	cudaStatus = cudaMemcpy(adjSize, adjSize_, sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}
    // Launch a kernel on the GPU with one thread for each element.
    addKernel<<<*imgW_, *imgH_>>>(imgW,imgH,distances,sampleR,sampleG,sampleB,targetR,targetG,targetB,adjSize);

    // Check for any errors launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }
    
    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
        goto Error;
    }

    // Copy output vector from GPU buffer to host memory.
    cudaStatus = cudaMemcpy(distances_, distances, *imgW * *imgH * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
	cudaFree(imgW);
	cudaFree(imgH);
	cudaFree(targetW);
	cudaFree(targetH);
	cudaFree(distances);
	cudaFree(sampleR);
	cudaFree(sampleG);
	cudaFree(sampleB);
	cudaFree(targetR);
	cudaFree(targetG);
	cudaFree(targetB);
	cudaFree(adjSize);
    
    return cudaStatus;
}

void CreateTexture()
{
	cout << "Entered the texture creation function2222" << endl;
	resultR = new int[targetW*targetH];
	resultG = new int[targetW*targetH];
	resultB = new int[targetW*targetH];

	cout << "==Declared result's RGB vectors (1/x) - Process 2 out of x ==" << endl;
	cout << "targetW: " << targetW << endl;
	cout << "targetH: " << targetH << endl;
	cout << "----" << endl;
	cout << "sampleW: " << sampleW << endl;
	cout << "sampleH: " << sampleH << endl;


	float* difference = new float[sampleW*sampleH];

	for (int j = 0; j < targetH; j++)
	{
		for (int i = 0; i < targetW; i++)
		{
			int* bestPixelPos = 0;
			vector<int> pixelsTarget = GetPixelsTarget(1, targetW, targetH);
			float lowestDistance = INFINITY;

			cudaError_t cudaStatus = addWithCuda(&sampleW, &sampleH, &targetW, &targetH, difference, sampleR, sampleG, sampleB, targetR, targetG, targetB, &sizeAdj);
			if (cudaStatus != cudaSuccess)
			{
				return;
			}

			for (int y = 0; y < sampleH; y++)
			{
				for (int x = 0; x < sampleW; x++)
				{
					float diff = difference[y * sampleW + x];
					if (diff < lowestDistance)
					{
						lowestDistance = diff;
						bestPixelPos = &sample[y * sampleW + x];
					}
				}
			}

			resultR[j * sampleW + i] = sampleR[*bestPixelPos];
			resultG[j * sampleW + i] = sampleG[*bestPixelPos];
			resultB[j * sampleW + i] = sampleB[*bestPixelPos];

			//cout << "Pixel color: " << j * sampleW + i << " - " << resultR[j * sampleW + i] << " " << resultG[j * sampleW + i] << " " << resultB[j * sampleW + i] << endl;
		}
	}
	return;
}


int main()
{
	ReadFile("sample.ppm", "texture.ppm");
	CreateTexture();
	WriteFile("output.ppm");
	cout << "End of the program" << endl;
	system("pause");
	return 0;
}