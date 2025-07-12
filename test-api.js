const https = require('https');

const postData = JSON.stringify({
    text: 'The sky is blue'
});

const options = {
    hostname: 'func-fact-checker-demo.azurewebsites.net',
    port: 443,
    path: '/api/fact_check_function',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
        'Origin': 'http://localhost:3000'
    }
};

console.log('Making request to:', `https://${options.hostname}${options.path}`);
console.log('Request options:', options);

const req = https.request(options, (res) => {
    console.log(`statusCode: ${res.statusCode}`);
    console.log(`headers:`, res.headers);

    let data = '';
    res.on('data', (chunk) => {
        data += chunk;
    });

    res.on('end', () => {
        console.log('Response:', data);
        try {
            const jsonData = JSON.parse(data);
            console.log('Parsed JSON:', jsonData);
        } catch (e) {
            console.log('Failed to parse JSON:', e.message);
        }
    });
});

req.on('error', (error) => {
    console.error('Request error:', error);
});

req.write(postData);
req.end();
