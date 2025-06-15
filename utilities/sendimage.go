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

const (
	targetURL = "https://fy0ziio70a.execute-api.eu-west-2.amazonaws.com/upload" // Replace with your actual target URL
)

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

	// Build custom HTTP request
	req, err := http.NewRequest("POST", targetURL, bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Printf("Error creating request: %v\n", err)
		return
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("Error making request: %v\n", err)
		return
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("Error reading response: %v\n", err)
		return
	}
	fmt.Printf("Response status: %s\n", resp.Status)
	fmt.Printf("Response body: %s\n", string(body))
}
