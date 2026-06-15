from flask import Flask, jsonify, render_template

# 1. Initialize the app
app = Flask(__name__)


# 2. Define the web URL paths
@app.route('/', methods=['GET'])
def home():
    return render_template(
        'index.html',
        service='Threat Intelligence Dashboard API',
        status='Secured against All Threats'
    )


@app.route('/status', methods=['GET'])
def get_status():
    return jsonify({
        'service': 'Threat Intelligence Dashboard API',
        'status': 'Secured against All Threats'
    })


# 3. Run the development server
if __name__ == '__main__':
    app.run(debug=False)
