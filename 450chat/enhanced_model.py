import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.preprocessing import StandardScaler
import pickle
import warnings
warnings.filterwarnings('ignore')

class EnhancedSurfModel:
    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()
        self.feature_importances = None
        
    def engineer_features(self, data):
        """Enhanced feature engineering"""
        df = data.copy()
        
        # Wave power interactions
        df['wave_power_normalized'] = df['Wave Power'] / df['Surf Height: Size']
        
        # Combined swell features
        df['total_swell_height'] = df['Primary -> height']
        for i in range(1, 4):
            height_col = f'Seconday {i} -> height'
            if height_col in df.columns:
                df['total_swell_height'] += df[height_col].fillna(0)
        
        # Wind-wave interaction
        df['wind_wave_alignment'] = np.abs(df['Wind Direction (Angle)'] - df['Surf Height: Angle']).apply(
            lambda x: min(x, 360-x)
        )
        
        # Wave period features
        df['wave_steepness'] = df['Surf Height: Size'] / df['Surf Height: Period']
        
        return df

    def prepare_features(self, df):
        """Prepare feature matrix"""
        # Base features
        feature_cols = [
            'Surf Height: Size', 'Surf Height: Period', 'Surf Height: Angle',
            'Wave Power', 'Primary Wind Speed', 'Wind Direction (Angle)',
            'wave_power_normalized', 'total_swell_height', 'wind_wave_alignment',
            'wave_steepness'
        ]
            
        return df[feature_cols]

    def fit(self, X_train, y_train):
        """Train the enhanced model"""
        # Create ensemble
        rf = RandomForestRegressor(
            n_estimators=200,
            max_depth=20,
            min_samples_leaf=1,
            min_samples_split=2,
            random_state=42
        )
        
        # Train model
        rf.fit(X_train, y_train)
        
        # Store feature importances
        self.feature_importances = pd.DataFrame({
            'Feature': X_train.columns,
            'Importance': rf.feature_importances_
        }).sort_values('Importance', ascending=False)
        
        # Use RF as primary model
        self.model = rf
        
    def predict(self, X):
        """Generate predictions with confidence scores"""
        predictions = self.model.predict(X)
        
        # Get prediction intervals from RF
        tree_predictions = np.array([tree.predict(X) for tree in self.model.estimators_])
        confidence = 1.96 * np.std(tree_predictions, axis=0)
        
        return predictions, confidence
        
    def save(self, filepath):
        """Save the model"""
        with open(filepath, 'wb') as f:
            pickle.dump(self, f)
    
    @classmethod
    def load(cls, filepath):
        """Load a saved model"""
        with open(filepath, 'rb') as f:
            return pickle.load(f)

if __name__ == "__main__":
    print("Loading data...")
    # Load data
    data = pd.read_csv('waves_statsV2.csv')
    
    print("Creating and training model...")
    # Create and train model
    model = EnhancedSurfModel()
    
    # Engineer features
    processed_data = model.engineer_features(data)
    
    # Prepare features and target
    X = model.prepare_features(processed_data)
    y = processed_data['Star Rating']
    
    # Train/test split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    print("Training model...")
    # Train model
    model.fit(X_train, y_train)
    
    # Generate predictions
    print("Testing model...")
    predictions, confidence = model.predict(X_test)
    
    # Evaluate
    mae = mean_absolute_error(y_test, predictions)
    r2 = r2_score(y_test, predictions)
    
    print(f"\nModel Performance:")
    print(f"Mean Absolute Error: {mae:.4f}")
    print(f"R-squared Score: {r2:.4f}")
    print("\nMost Important Features:")
    print(model.feature_importances.head(10))
    
    # Save model
    print("\nSaving model to enhanced_surf_model.pkl...")
    model.save('enhanced_surf_model.pkl')
    print("Done! Model saved successfully.")