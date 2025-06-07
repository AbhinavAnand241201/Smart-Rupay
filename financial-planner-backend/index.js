require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Initialize Express app
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Google Gemini AI
const apiKey = process.env.GEMINI_API_KEY;
if (!apiKey) {
  console.error('GEMINI_API_KEY is not set in the .env file');
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(apiKey);

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Financial Planner API is running' });
});

// Generate financial plan endpoint
app.post('/api/generate-plan', async (req, res) => {
  try {
    const { monthlyIncome, monthlyExpenses, financialGoals } = req.body;

    // Input validation
    if (!monthlyIncome || isNaN(monthlyIncome) || monthlyIncome <= 0) {
      return res.status(400).json({ error: 'Please provide a valid monthly income' });
    }

    if (!monthlyExpenses || isNaN(monthlyExpenses) || monthlyExpenses < 0) {
      return res.status(400).json({ error: 'Please provide valid monthly expenses' });
    }

    // Construct the prompt for Gemini
    const prompt = `
    You are a financial planning assistant. Create a structured financial plan based on the following information:
    - Monthly Income: $${monthlyIncome}
    - Monthly Expenses: $${monthlyExpenses}
    - Financial Goals: ${financialGoals || 'Not specified'}

    Generate a response in the following JSON format:
    {
      "emergencyFundPlan": {
        "title": "Emergency Fund",
        "iconName": "shield.lefthalf.filled",
        "summary": "A brief summary of the emergency fund recommendation",
        "steps": [
          "Step 1 description",
          "Step 2 description"
        ]
      },
      "budgetAllocationPlan": {
        "title": "Budget Allocation",
        "iconName": "chart.pie.fill",
        "summary": "A brief summary of the budget allocation",
        "allocations": [
          {"category": "Needs", "percentage": 50, "amount": 2500, "color": "blue"},
          {"category": "Wants", "percentage": 30, "amount": 1500, "color": "orange"},
          {"category": "Savings", "percentage": 20, "amount": 1000, "color": "green"}
        ]
      },
      "longTermGoalSuggestion": {
        "title": "Long-Term Goals",
        "iconName": "flag.fill",
        "summary": "A brief summary of long-term goal suggestions",
        "steps": [
          "Step 1 description",
          "Step 2 description"
        ]
      }
    }
    
    Important:
    - Only return valid JSON, no other text
    - Ensure the response can be parsed with JSON.parse()
    - Use the exact field names and structure shown above
    - Keep the response focused on educational financial principles
    - Do not provide specific investment advice
    `;

    // Call Gemini API
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
    const result = await model.generateContent(prompt);
    const responseText = await result.response.text();
    
    // Parse the response
    const responseJson = JSON.parse(responseText.trim());
    
    // Return the structured response
    res.json(responseJson);
    
  } catch (error) {
    console.error('Error generating financial plan:', error);
    res.status(500).json({ 
      error: 'Failed to generate financial plan',
      details: error.message 
    });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
