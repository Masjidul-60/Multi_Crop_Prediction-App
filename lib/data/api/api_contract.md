# CropDoc Backend API Specification (v1)

This specification defines the exact contract between the CropDoc Flutter mobile app and the AI inference backend service.

---

## Base URL
Default: `https://api.cropdoc.app` (configurable in app settings / developer mode)

---

## 1. Health Check
Checks if the inference service and model weights are ready.

- **Endpoint**: `GET /v1/health`
- **Request Headers**: None required
- **Response**: `200 OK`
```json
{
  "status": "ok",
  "model_version": "v1.2.0-rc3"
}
```

---

## 2. Leaf Disease Prediction
Submits a leaf image for crop identification and disease classification.

- **Endpoint**: `POST /v1/predict`
- **Content-Type**: `multipart/form-data`
- **Payload**:
  - `image`: Binary file (JPEG format, resized client-side so max dimension $\le 1024$ px, quality ~85%).
  
### Success Response: `200 OK`
```json
{
  "request_id": "req_8f19bc01a4e543f",
  "crop": {
    "name": "rice",
    "confidence": 0.98
  },
  "predictions": [
    {
      "label": "rice/blast",
      "crop": "rice",
      "disease": "blast",
      "confidence": 0.91
    },
    {
      "label": "rice/brown_spot",
      "crop": "rice",
      "disease": "brown_spot",
      "confidence": 0.06
    },
    {
      "label": "rice/bacterial_leaf_blight",
      "crop": "rice",
      "disease": "bacterial_leaf_blight",
      "confidence": 0.02
    }
  ],
  "status": "confident",
  "reasons": ["energy", "maha"],
  "model_version": "v1.2.0-rc3",
  "inference_ms": 142
}
```

### Status Definition
- `"confident"`: High confidence match on a known crop and disease class.
- `"uncertain"`: The leaf matches known crops, but top prediction confidence is below the threshold or multiple classes are competing.
- `"unknown"`: Model out-of-distribution (OOD) flag or leaf not recognised as one of the supported crop categories.

### Optional Fields
- `reasons`: `["energy", "maha"]` or other OOD / uncertainty indicator flags from the model ensemble.

---

## 3. Error Responses
All error responses return standard HTTP error codes with a JSON error payload:
```json
{
  "error_code": "INVALID_IMAGE",
  "message": "The provided file is not a valid JPEG or PNG image."
}
```

### Error Codes & HTTP Status:
- `400 Bad Request`: `INVALID_IMAGE` - File corrupted or unsupported format.
- `413 Payload Too Large`: `IMAGE_TOO_LARGE` - Upload exceeds allowable size (must be under 5 MB).
- `422 Unprocessable Entity`: `NO_LEAF_DETECTED` - No crop leaf could be detected in the provided image.
- `500 Internal Server Error`: `SERVER_ERROR` - Unhandled inference exception on the server.
- `503 Service Unavailable`: `MODEL_LOADING` - Model is warming up or server overloaded.

---

## 4. User Feedback Stub (Future Endpoint)
- **Endpoint**: `POST /v1/feedback`
- **Payload**:
```json
{
  "request_id": "req_8f19bc01a4e543f",
  "is_correct": false,
  "user_note": "Farmer believes this is zinc deficiency instead.",
  "suggested_label": "rice/zinc_deficiency"
}
```
- **Response**: `200 OK` `{"status": "recorded"}`
