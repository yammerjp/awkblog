  // Need to load `browser-image-compression`

  async function uploadImage(originalFile, printLog) {
      const file = await imageCompression(originalFile, {maxSizeMB: 1, maxWidthOrHeight: 1920})
      printLog(`Form Submitted! Timestamp: ${event.timeStamp} (file name:${file.name}, size: ${file.size}, type: ${file.type})`);
      printLog("start to fetch presigned upload url")
      const res = await fetch("/api/v1/images/uploading-sign", {
        headers: { "Content-Type": "application/json;" },
        body: JSON.stringify({ type: file.type }),
        method: 'POST',
      }).then(r => {
        if (!r.ok) {
          throw new Error("failed to communicate with presign endpoint")
        }
        return r.json()
      })
      printLog("success to fetch presigned upload url")
      printLog(`response: ${JSON.stringify(res)}`);

      const postData = new FormData()
      for(const key in res.data) {
        postData.append(key, res.data[key]);
      }
      postData.append('file', file);

      printLog("start to post to S3")
      const resAws = await fetch(res.upload_url, {
        method: 'POST',
        body: postData,
      })

      printLog("success to post to S3")
      printLog(`response: ${await resAws.text()}`)
      printLog(`uploaded_url: ${res.public_url}`)
      if (!resAws.ok) {
        throw new Error("failed to communicate with aws")
      }
      return res.public_url
  }


