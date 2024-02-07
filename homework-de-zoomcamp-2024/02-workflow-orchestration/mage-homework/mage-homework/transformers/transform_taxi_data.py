if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

import pandas as pd

@transformer
def transform(data, *args, **kwargs):
    # Specify your transformation logic here

        zero_passengers_df = data[data['passenger_count'] == 0]
        zero_passengers_count = zero_passengers_df.loc[zero_passengers_df['passenger_count'] == 0, 'passenger_count'].count()

        zero_trip_distance_df = data[data['trip_distance'] == 0]
        zero_trip_distance_count = zero_trip_distance_df.loc[zero_trip_distance_df['trip_distance'] == 0, 'trip_distance'].count()

        transformed_df = data[(data['passenger_count'] > 0) & (data['trip_distance'] > 0)].copy()

        transformed_data_shape = transformed_df.shape
        print(f'Pre-processing: records with zero passengers: {zero_passengers_count}')
        print(f'Pre-processing: records with zero trip distance: {zero_trip_distance_count}')
        print(f'Pre-processing: shape of transformed data: {transformed_data_shape}')

        # Function to convert CamelCase to snake_case with specific column renaming
        def camel_to_snake(column_name):
            # Lowercase the column name
            lowercase_name = column_name.lower()
            # Specific renaming based on provided examples
            specific_renaming = {
                'vendorid': 'vendor_id',
                'ratecodeid': 'ratecode_id',
                'pulocationid': 'pu_location_id',
                'dolocationid': 'do_location_id'
            }
            return specific_renaming.get(lowercase_name, lowercase_name)

        # Rename columns from CamelCase to snake_case
        transformed_df.columns = [camel_to_snake(col) for col in transformed_df.columns]
        print('Updated column_names:', transformed_df.columns)

        return transformed_df


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
  
    # Assertion to check if 'vendor_id' contains existing values
    assert 'vendor_id' in output.columns, "Error: 'vendor_id' column is missing"
    assert output['vendor_id'].nunique() > 0, "Error: 'vendor_id' column has no existing values"

    # Assertion to check if 'passenger_count' is greater than 0
    assert (output['passenger_count'] > 0).all(), "Error: 'passenger_count' must be greater than 0"

    # Assertion to check if 'trip_distance' is greater than 0
    assert (output['trip_distance'] > 0).all(), "Error: 'trip_distance' must be greater than 0"
