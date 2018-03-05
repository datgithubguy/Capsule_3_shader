using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Video;
//using UnityEditor.Audio;

public class PLayerManager : MonoBehaviour {

	AudioSource	audioSource;
	VideoPlayer	videoPlayer;
	Material	material;
	bool        isStarted;
	float		t = 0;
	// Use this for initialization
	void Start () {
		isStarted = false;
		audioSource = GetComponent< AudioSource >();
		videoPlayer = GetComponent< VideoPlayer >();
		videoPlayer.Prepare();
		material = GetComponent< MeshRenderer >().sharedMaterial;
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKeyDown(KeyCode.Space))
		{
			isStarted = true;
			if (audioSource != null)
			{
				audioSource.time = 0;
				audioSource.Play();
			}
			videoPlayer.time = 0;
			videoPlayer.Play();
			t = Time.timeSinceLevelLoad;
		}
		videoPlayer.started += OnStart;

		//if (videoPlayer.isPlaying)
		if (isStarted == true)
			material.SetFloat("truc", Time.timeSinceLevelLoad - t);
		else
			material.SetFloat("truc", value : 0.0f);
	}

	void OnStart(VideoPlayer vp)
	{
		Debug.Log("Video started !");
	}
}
