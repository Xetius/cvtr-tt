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

type ImagePayload struct {
	Filename string `json:"filename"`
	Content  string `json:"content"`
	FileType string `json:"filetype"`
}

func main() {
	targetURL := os.Getenv("IMAGE_UPLOAD_URL")
	if targetURL == "" {
		fmt.Println("Error: TARGET_URL environment variable is not set.")
		return
	}

	if len(os.Args) < 2 {
		fmt.Println("Usage: sendimage <image_filename>")
		return
	}

	filename := os.Args[1]

	data, err := ioutil.ReadFile(filename)
	if err != nil {
		fmt.Printf("Error reading file %s: %v\n", filename, err)
		return
	}

	fileType := http.DetectContentType(data[:512])
	fmt.Println("filetype: ", fileType)

	encoded := base64.StdEncoding.EncodeToString(data)

	payload := ImagePayload{
		Filename: filename,
		Content:  encoded,
		FileType: fileType,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		fmt.Printf("Error marshaling JSON: %v\n", err)
		return
	}

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
