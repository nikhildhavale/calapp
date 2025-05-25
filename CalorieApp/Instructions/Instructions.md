AI-Powered Food Logger App

Goal

Build an iOS app using SwiftUI that enables users to:
	•	Capture a photo of food
	•	Analyze the food image using the OpenAI Vision API to identify ingredients and estimate calorie content
	•	Edit the detected ingredients and calorie estimates
	•	Save meals to a log and display them in a calendar-style history

Requirements
	•	Platform: iOS 16+
	•	Architecture: MVVM (Model-View-ViewModel)
	•	UI Framework: SwiftUI
	•	Image Picker: Use PhotosPicker from PhotosUI
	•	Image Analysis: Use OpenAI Vision API with prompt engineering to extract food metadata
	•	Data Editing: Editable list of ingredients and calories
	•	Data Storage: Persist logs locally (Core Data, UserDefaults, or FileManager)
	•	History View: Calendar interface to browse and select past logs

Features Overview
	1.	Photo Input

	•	Provide UI for the user to take or select a food photo.
	•	Store selected image in view model for analysis.

	2.	Food Analysis (OpenAI Vision API)

	•	Encode the image to base64.
	•	Send to OpenAI Vision API with an appropriate prompt (e.g. “List ingredients and calorie estimates for the food in this image.”).
	•	Parse and store the response as a list of ingredient items.

	3.	Editable Ingredients View

	•	Display ingredients and calorie estimates in a List.
	•	Allow the user to edit both name and calorie value for each item.

	4.	Save to Log

	•	Combine ingredients and metadata into a MealLog model.
	•	Save the log to persistent storage (Core Data or file-based).
	•	Each log should be associated with a date and unique ID.

	5.	Calendar History View

	•	Display a monthly calendar grid or scrollable list.
	•	Highlight or mark dates with saved logs.
	•	Tap a date to view or edit that day’s meal log.

