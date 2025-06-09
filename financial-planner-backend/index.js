require('dotenv').config();
const express = require('express');
const cors = require('cors'); 
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors()); 
app.use(express.json()); 

const apiKey = process.env.GEMINI_API_KEY;
if (!apiKey) {
  console.error('FATAL ERROR: GEMINI_API_KEY is not set in the .env file.');
  process.exit(1);
}
const genAI = new GoogleGenerativeAI(apiKey);

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Financial Planner API is running' });
});

app.post('/api/generate-plan', async (req, res) => {
  try {
    const { monthlyIncome, monthlyExpenses, financialGoals } = req.body;

    if (!monthlyIncome || isNaN(monthlyIncome) || monthlyIncome <= 0) {
      return res.status(400).json({ error: 'Valid monthlyIncome is required.' });
    }
    if (monthlyExpenses === undefined || isNaN(monthlyExpenses) || monthlyExpenses < 0) {
        return res.status(400).json({ error: 'Valid monthlyExpenses is required.' });
    }

    const prompt = `
      You are a helpful financial planning assistant. Your task is to create a structured financial plan based on the user's data.
      User Data:
      - Monthly Income: $${monthlyIncome}
      - Monthly Expenses: $${monthlyExpenses}
      - Financial Goals: "${financialGoals || 'General financial stability'}"

      Generate a response strictly in the following JSON format. Do not include any text, explanations, or markdown formatting before or after the JSON object.

      {
        "emergencyFundPlan": {
          "title": "Build Your Emergency Fund",
          "iconName": "shield.lefthalf.filled",
          "summary": "An emergency fund is your financial safety net for unexpected costs. Aim for 3-6 months of essential living expenses.",
          "steps": [
            "Your 3-month target is $${(monthlyExpenses * 3).toFixed(2)}.",
            "Open a separate high-yield savings account to keep these funds accessible but distinct from your daily checking account.",
            "Automate a fixed amount from your paycheck to this fund weekly or monthly."
          ]
        },
        "budgetAllocationPlan": {
          "title": "Budget Using the 50/30/20 Rule",
          "iconName": "chart.pie.fill",
          "summary": "The 50/30/20 framework is a simple way to manage your money. It divides your income into Needs, Wants, and Savings.",
          "allocations": [
            {"category": "Needs", "percentage": 0.5, "amount": ${monthlyIncome * 0.5}, "color": "#007AFF"},
            {"category": "Wants", "percentage": 0.3, "amount": ${monthlyIncome * 0.3}, "color": "#FF9500"},
            {"category": "Savings & Debt", "percentage": 0.2, "amount": ${monthlyIncome * 0.2}, "color": "#34C759"}
          ]
        },
        "longTermGoalSuggestion": {
          "title": "Plan for Your Goals",
          "iconName": "flag.fill",
          "summary": "Use your 'Savings & Debt' portion to work towards your long-term ambitions like '${financialGoals || 'financial independence'}'",
          "steps": [
            "Prioritize paying off high-interest debt (like credit cards) first.",
            "Once debt is managed, begin investing in low-cost, diversified funds to build wealth over time.",
            "Consistency is more important than timing the market."
          ]
        }
      }
    `;

    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
    const result = await model.generateContent(prompt);
    const responseText = await result.response.text();
    
    let responseJson;
    try {
        const jsonStringMatch = responseText.match(/\{[\s\S]*\}/);
        if (!jsonStringMatch) {
            throw new Error("No valid JSON object found in the AI response.");
        }
        responseJson = JSON.parse(jsonStringMatch[0]);
    } catch (parseError) {
        console.error("CRITICAL: Failed to parse JSON from AI response.", {
            responseText: responseText,
            parseError: parseError.message
        });
        throw new Error("AI returned a malformed response.");
    }
    
    res.json(responseJson);
    
  } catch (error) {
    console.error('Error in /api/generate-plan:', error);
    res.status(500).json({ 
      error: 'Failed to generate financial plan.',
      details: error.message 
    });
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});