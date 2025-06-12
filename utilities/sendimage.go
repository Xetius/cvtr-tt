package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

const targetURL = "http://myurl" // Replace with your actual target URL

type ImagePayload struct {
	Filename string `json:"filename"`
	Content  string `json:"content"` // base64-encoded
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: sendimage <image_filename>")
		return
	}

	filename := os.Args[1]

	// Read the image file
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		fmt.Printf("Error reading file %s: %v\n", filename, err)
		return
	}

	// Encode the image to base64
	encoded := base64.StdEncoding.EncodeToString(data)

	// Prepare the payload
	payload := ImagePayload{
		Filename: filename,
		Content:  encoded,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		fmt.Printf("Error marshaling JSON: %v\n", err)
		return
	}

	// Send POST request
	resp, err := http.Post(targetURL, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Printf("HTTP request error: %v\n", err)
		return
	}
	defer resp.Body.Close()

	// Read and display the response
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("Error reading response: %v\n", err)
		return
	}

	fmt.Printf("Response status: %s\n", resp.Status)
	fmt.Printf("Response body: %s\n", string(body))
}
