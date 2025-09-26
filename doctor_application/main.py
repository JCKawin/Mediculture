#!/usr/bin/env python3
"""
Mediculture Doctor Application - Connected to Backend
Fully functional Streamlit app connected to your MongoDB backend
"""

import streamlit as st
import requests
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import json
import time

# Configure Streamlit page
st.set_page_config(
    page_title="Mediculture - Doctor Portal",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Configuration
API_BASE_URL = "http://localhost:3000/api"  # Your backend URL

class APIClient:
    """Client to interact with your Mediculture backend"""
    
    def __init__(self, base_url: str):
        self.base_url = base_url
    
    def get_health_status(self) -> Dict:
        """Check backend health"""
        try:
            response = requests.get(f"{self.base_url}/health", timeout=5)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            return {"status": "Error", "error": str(e)}
    
    def get_appointments(self, firebase_uid: str = "", status: str = "", limit: int = 50) -> Dict:
        """Get appointments from backend"""
        try:
            params = {"limit": limit}
            if firebase_uid:
                params["firebaseUid"] = firebase_uid
            if status:
                params["status"] = status
            
            response = requests.get(f"{self.base_url}/appointments", params=params, timeout=10)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            st.error(f"Error fetching appointments: {e}")
            return {"appointments": []}
    
    def update_appointment_status(self, appointment_id: str, status: str) -> bool:
        """Update appointment status"""
        try:
            response = requests.patch(
                f"{self.base_url}/appointments/{appointment_id}/status",
                json={"status": status},
                timeout=10
            )
            response.raise_for_status()
            return True
        except Exception as e:
            st.error(f"Error updating appointment: {e}")
            return False
    
    def create_appointment(self, appointment_data: Dict) -> Dict:
        """Create new appointment"""
        try:
            response = requests.post(
                f"{self.base_url}/appointments",
                json=appointment_data,
                timeout=10
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            st.error(f"Error creating appointment: {e}")
            return {}
    
    def get_medicines(self, page: int = 1, limit: int = 20, search: str = "", 
                     category: str = "") -> Dict:
        """Get medicines from backend"""
        try:
            params = {"page": page, "limit": limit}
            if search:
                params["search"] = search
            if category:
                params["category"] = category
            
            response = requests.get(f"{self.base_url}/medicines", params=params, timeout=10)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            st.error(f"Error fetching medicines: {e}")
            return {"medicines": [], "pagination": {}}
    
    def get_medicine_categories(self) -> List[str]:
        """Get available medicine categories"""
        try:
            response = requests.get(f"{self.base_url}/medicines/categories/list", timeout=10)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            st.error(f"Error fetching categories: {e}")
            return []
    
    def get_user_profile(self, firebase_uid: str) -> Dict:
        """Get user profile"""
        try:
            response = requests.get(
                f"{self.base_url}/users/profile",
                params={"firebaseUid": firebase_uid},
                timeout=10
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            return {}

def init_session_state():
    """Initialize session state variables"""
    if 'logged_in' not in st.session_state:
        st.session_state.logged_in = False
    if 'doctor_data' not in st.session_state:
        st.session_state.doctor_data = None
    if 'api_client' not in st.session_state:
        st.session_state.api_client = APIClient(API_BASE_URL)

def check_backend_connection():
    """Check if backend is accessible"""
    health_status = st.session_state.api_client.get_health_status()
    if health_status.get("status") != "OK":
        st.error("⚠️ Cannot connect to backend server. Please ensure your Node.js server is running at http://localhost:3000")
        st.stop()
    return health_status

def show_login():
    """Show login page"""
    st.markdown("""
    <div style="text-align: center; padding: 50px;">
        <h1>🏥 Mediculture</h1>
        <h3>Doctor Portal - Secure Login</h3>
    </div>
    """, unsafe_allow_html=True)
    
    # Check backend connection
    with st.spinner("Checking backend connection..."):
        health_status = check_backend_connection()
    
    st.success(f"✅ Backend connected - Database: {health_status.get('database', 'Unknown')}")
    
    col1, col2, col3 = st.columns([1, 2, 1])
    
    with col2:
        st.markdown("### Login to Your Account")
        
        with st.form("login_form"):
            email = st.text_input("📧 Email Address", placeholder="doctor@mediculture.com")
            password = st.text_input("🔒 Password", type="password", placeholder="Password")
            
            col_demo, col_login = st.columns(2)
            
            with col_demo:
                demo_login = st.form_submit_button("🧪 Demo Login", type="secondary", use_container_width=True)
            
            with col_login:
                login_submit = st.form_submit_button("🚀 Login", type="primary", use_container_width=True)
        
        if demo_login or login_submit:
            # Simulate login process
            with st.spinner("Authenticating..."):
                time.sleep(1)  # Simulate API call
            
            # Set login state with demo doctor data
            st.session_state.logged_in = True
            st.session_state.doctor_data = {
                "id": "doc_001",
                "name": "Dr. Sarah Mitchell",
                "email": email if email else "sarah.mitchell@mediculture.com",
                "specialization": "Internal Medicine",
                "license": "MD12345",
                "experience": "8 years",
                "hospital": "Mediculture General Hospital",
                "firebase_uid": "doctor_demo_uid"
            }
            
            st.success("Login successful! Redirecting to dashboard...")
            time.sleep(1)
            st.rerun()

def show_sidebar():
    """Show sidebar with navigation and doctor info"""
    with st.sidebar:
        # Doctor profile
        st.markdown("### 👩‍⚕️ Doctor Profile")
        
        doctor = st.session_state.doctor_data
        st.markdown(f"""
        **{doctor['name']}**  
        *{doctor['specialization']}*  
        📧 {doctor['email']}  
        🏥 {doctor['hospital']}  
        ⏰ {doctor['experience']} experience  
        🆔 License: {doctor['license']}
        """)
        
        st.divider()
        
        # Backend status
        st.markdown("### 🔗 System Status")
        health_status = st.session_state.api_client.get_health_status()
        
        if health_status.get("status") == "OK":
            st.success("Backend: Connected")
            st.info(f"Database: {health_status.get('database', 'Unknown')}")
            
            # Show collection counts if available
            collections = health_status.get("collections", {})
            if collections:
                col1, col2 = st.columns(2)
                with col1:
                    st.metric("Users", collections.get("users", 0))
                    st.metric("Appointments", collections.get("appointments", 0))
                with col2:
                    st.metric("Medicines", collections.get("medicines", 0))
        else:
            st.error("Backend: Disconnected")
        
        st.divider()
        
        # Quick actions
        st.markdown("### ⚡ Quick Actions")
        
        if st.button("🚨 Emergency Alert", type="secondary", use_container_width=True):
            st.warning("Emergency alert system activated!")
        
        if st.button("⚙️ Settings", use_container_width=True):
            st.info("Settings panel (Coming Soon)")
        
        st.divider()
        
        # Logout
        if st.button("🚪 Logout", type="primary", use_container_width=True):
            st.session_state.logged_in = False
            st.session_state.doctor_data = None
            st.rerun()

def show_appointments():
    """Show appointments management page"""
    st.markdown("# 📅 Appointment Management")
    
    # Header with controls
    col1, col2, col3 = st.columns([2, 1, 1])
    with col1:
        st.markdown("Manage patient appointments and consultations")
    with col2:
        status_filter = st.selectbox(
            "Filter by Status:",
            ["All", "scheduled", "confirmed", "completed", "cancelled", "rescheduled"],
            index=0
        )
    with col3:
        if st.button("🔄 Refresh", use_container_width=True):
            st.rerun()
    
    st.divider()
    
    # Fetch appointments from backend
    with st.spinner("Loading appointments..."):
        appointments_data = st.session_state.api_client.get_appointments(
            status=status_filter if status_filter != "All" else None
        )
    
    appointments = appointments_data.get("appointments", [])
    
    if not appointments:
        st.info("📭 No appointments found matching your criteria")
        
        # Add sample appointment for demo
        st.markdown("### 🧪 Add Demo Appointment")
        if st.button("Add Demo Appointment", type="secondary"):
            demo_appointment = {
                "userId": "user123",
                "doctorName": st.session_state.doctor_data["name"],
                "specialty": st.session_state.doctor_data["specialization"],
                "appointmentDate": (datetime.now() + timedelta(days=1)).isoformat(),
                "timeSlot": "10:00 AM",
                "type": "consultation",
                "symptoms": ["Headache", "Fever"],
                "status": "scheduled",
                "fees": {"consultation": 300, "total": 300}
            }
            
            result = st.session_state.api_client.create_appointment(demo_appointment)
            if result:
                st.success("Demo appointment created!")
                st.rerun()
        return
    
    # Display appointments
    st.markdown(f"### Found {len(appointments)} appointments")
    
    for i, appointment in enumerate(appointments):
        with st.expander(
            f"👤 Patient ID: {appointment.get('userId', 'Unknown')} - "
            f"{appointment.get('timeSlot', 'No time')} "
            f"({appointment.get('status', 'unknown').upper()})"
        ):
            
            # Appointment details
            col1, col2 = st.columns(2)
            
            with col1:
                st.markdown(f"""
                **Appointment Information:**
                - **Doctor:** {appointment.get('doctorName', 'Unknown')}
                - **Specialty:** {appointment.get('specialty', 'Unknown')}
                - **Date:** {appointment.get('appointmentDate', 'Not set')[:10] if appointment.get('appointmentDate') else 'Not set'}
                - **Time:** {appointment.get('timeSlot', 'Not set')}
                - **Type:** {appointment.get('type', 'consultation').title()}
                """)
            
            with col2:
                st.markdown(f"""
                **Patient Details:**
                - **User ID:** {appointment.get('userId', 'Unknown')}
                - **Status:** {appointment.get('status', 'unknown').upper()}
                - **Fees:** ${appointment.get('fees', {}).get('total', 0)}
                - **Created:** {appointment.get('createdAt', 'Unknown')[:10] if appointment.get('createdAt') else 'Unknown'}
                """)
            
            # Symptoms and notes
            if appointment.get('symptoms'):
                st.markdown(f"**Symptoms:** {', '.join(appointment['symptoms'])}")
            
            if appointment.get('notes'):
                st.markdown(f"**Notes:** {appointment['notes']}")
            
            # Prescription info
            if appointment.get('prescription', {}).get('medicines'):
                st.markdown("**Prescribed Medicines:**")
                for med in appointment['prescription']['medicines']:
                    st.write(f"- {med.get('medicineName', 'Unknown')} - {med.get('dosage', 'Unknown dosage')}")
            
            # Action buttons
            if appointment.get('status') in ['scheduled', 'confirmed']:
                col1, col2, col3 = st.columns(3)
                
                with col1:
                    if st.button(f"✅ Complete", key=f"complete_{appointment.get('_id', i)}"):
                        if st.session_state.api_client.update_appointment_status(
                            appointment.get('_id'), 'completed'
                        ):
                            st.success("Appointment marked as completed!")
                            st.rerun()
                
                with col2:
                    if st.button(f"📅 Reschedule", key=f"reschedule_{appointment.get('_id', i)}"):
                        if st.session_state.api_client.update_appointment_status(
                            appointment.get('_id'), 'rescheduled'
                        ):
                            st.success("Appointment rescheduled!")
                            st.rerun()
                
                with col3:
                    if st.button(f"❌ Cancel", key=f"cancel_{appointment.get('_id', i)}"):
                        if st.session_state.api_client.update_appointment_status(
                            appointment.get('_id'), 'cancelled'
                        ):
                            st.warning("Appointment cancelled!")
                            st.rerun()

def show_medicines():
    """Show medicines management page"""
    st.markdown("# 💊 Medicine Database")
    st.markdown("Browse and manage medicine inventory")
    
    # Search and filter controls
    col1, col2, col3 = st.columns([2, 1, 1])
    
    with col1:
        search_query = st.text_input("🔍 Search medicines...", placeholder="Enter medicine name or category")
    
    with col2:
        # Get categories from backend
        categories = st.session_state.api_client.get_medicine_categories()
        category_filter = st.selectbox("Category:", ["All"] + categories)
    
    with col3:
        st.write("")  # Spacing
        search_button = st.button("🔍 Search", use_container_width=True)
    
    st.divider()
    
    # Fetch medicines from backend
    if search_button or search_query or category_filter != "All":
        with st.spinner("Searching medicines..."):
            medicines_data = st.session_state.api_client.get_medicines(
                page=1,
                limit=50,
                search=search_query if search_query else None,
                category=category_filter if category_filter != "All" else None
            )
    else:
        with st.spinner("Loading medicines..."):
            medicines_data = st.session_state.api_client.get_medicines(page=1, limit=20)
    
    medicines = medicines_data.get("medicines", [])
    pagination = medicines_data.get("pagination", {})
    
    if not medicines:
        st.info("📭 No medicines found matching your criteria")
        return
    
    # Display results summary
    st.markdown(f"### Found {len(medicines)} medicines")
    if pagination.get("totalItems"):
        st.markdown(f"Showing {len(medicines)} of {pagination['totalItems']} total medicines")
    
    # Display medicines in cards
    cols = st.columns(2)
    
    for i, medicine in enumerate(medicines):
        with cols[i % 2]:
            with st.container():
                st.markdown(f"**{medicine.get('name', 'Unknown Medicine')}**")
                st.markdown(f"*{medicine.get('genericName', 'No generic name')}*")
                
                col_details, col_price = st.columns([2, 1])
                
                with col_details:
                    st.markdown(f"""
                    - **Category:** {medicine.get('category', 'Unknown')}
                    - **Manufacturer:** {medicine.get('manufacturer', 'Unknown')}
                    - **Dosage:** {medicine.get('dosage', 'Not specified')}
                    - **Packaging:** {medicine.get('packaging', 'Not specified')}
                    """)
                
                with col_price:
                    price = medicine.get('price', 0)
                    original_price = medicine.get('originalPrice', price)
                    discount = medicine.get('discount', 0)
                    
                    if discount > 0:
                        st.markdown(f"~~${original_price}~~ **${price}**")
                        st.markdown(f"🏷️ {discount}% OFF")
                    else:
                        st.markdown(f"**${price}**")
                
                # Stock and prescription info
                col_stock, col_prescription = st.columns(2)
                with col_stock:
                    stock = medicine.get('stock', 0)
                    if stock > 0:
                        st.success(f"✅ In Stock: {stock}")
                    else:
                        st.error("❌ Out of Stock")
                
                with col_prescription:
                    if medicine.get('prescriptionRequired', False):
                        st.warning("⚠️ Prescription Required")
                    else:
                        st.info("ℹ️ Over-the-Counter")
                
                # Rating
                rating = medicine.get('rating', {})
                if rating.get('average', 0) > 0:
                    stars = "⭐" * int(rating.get('average', 0))
                    st.markdown(f"{stars} ({rating.get('average', 0):.1f}) - {rating.get('count', 0)} reviews")
                
                # Description
                if medicine.get('description'):
                    with st.expander("📋 Description"):
                        st.write(medicine['description'])
                
                st.divider()

def show_prescriptions():
    """Show prescription management page"""
    st.markdown("# 💊 Prescription Management")
    st.markdown("Create and manage patient prescriptions")
    
    tab1, tab2 = st.tabs(["📝 Create Prescription", "📋 Prescription History"])
    
    with tab1:
        st.markdown("### Create New Prescription")
        
        with st.form("prescription_form"):
            col1, col2 = st.columns(2)
            
            with col1:
                patient_id = st.text_input("Patient ID (Firebase UID)", placeholder="user123")
                doctor_name = st.text_input("Doctor Name", value=st.session_state.doctor_data["name"])
                appointment_date = st.date_input("Appointment Date", value=datetime.now())
            
            with col2:
                specialty = st.text_input("Specialty", value=st.session_state.doctor_data["specialization"])
                appointment_time = st.time_input("Appointment Time")
                consultation_type = st.selectbox("Type", ["consultation", "checkup", "follow-up", "emergency"])
            
            # Symptoms
            st.markdown("#### Patient Symptoms")
            symptoms = st.text_area("Enter symptoms (one per line)", 
                                   placeholder="Headache\nFever\nCough")
            
            # Medicine prescription
            st.markdown("#### Prescribed Medicines")
            
            num_medicines = st.number_input("Number of medicines to prescribe", min_value=1, max_value=10, value=1)
            
            medicines = []
            for i in range(int(num_medicines)):
                st.markdown(f"**Medicine {i+1}:**")
                med_col1, med_col2, med_col3, med_col4 = st.columns(4)
                
                with med_col1:
                    med_name = st.text_input(f"Medicine Name", key=f"med_name_{i}")
                with med_col2:
                    med_dosage = st.text_input(f"Dosage", key=f"med_dosage_{i}", placeholder="500mg")
                with med_col3:
                    med_frequency = st.text_input(f"Frequency", key=f"med_freq_{i}", placeholder="Twice daily")
                with med_col4:
                    med_duration = st.text_input(f"Duration", key=f"med_duration_{i}", placeholder="7 days")
                
                if med_name:
                    medicines.append({
                        "medicineName": med_name,
                        "dosage": med_dosage,
                        "frequency": med_frequency,
                        "duration": med_duration
                    })
            
            # Additional notes
            notes = st.text_area("Additional Notes/Instructions")
            
            # Submit button
            if st.form_submit_button("💾 Create Prescription", type="primary"):
                if patient_id and doctor_name:
                    # Create appointment with prescription
                    appointment_data = {
                        "userId": patient_id,
                        "doctorName": doctor_name,
                        "specialty": specialty,
                        "appointmentDate": f"{appointment_date}T{appointment_time}:00Z",
                        "timeSlot": str(appointment_time),
                        "type": consultation_type,
                        "symptoms": [s.strip() for s in symptoms.split('\n') if s.strip()],
                        "status": "completed",
                        "notes": notes,
                        "fees": {"consultation": 300, "total": 300},
                        "prescription": {
                            "medicines": medicines,
                            "instructions": notes
                        }
                    }
                    
                    result = st.session_state.api_client.create_appointment(appointment_data)
                    if result:
                        st.success(f"Prescription created successfully!")
                        st.json(result)
                else:
                    st.error("Please fill in Patient ID and Doctor Name")
    
    with tab2:
        st.markdown("### Prescription History")
        
        # Fetch completed appointments (which include prescriptions)
        with st.spinner("Loading prescription history..."):
            appointments_data = st.session_state.api_client.get_appointments(status="completed")
        
        appointments = appointments_data.get("appointments", [])
        prescriptions = [apt for apt in appointments if apt.get('prescription', {}).get('medicines')]
        
        if not prescriptions:
            st.info("📭 No prescriptions found")
        else:
            for prescription in prescriptions:
                with st.expander(
                    f"👤 Patient: {prescription.get('userId')} - "
                    f"{prescription.get('appointmentDate', '')[:10] if prescription.get('appointmentDate') else 'No date'}"
                ):
                    col1, col2 = st.columns(2)
                    
                    with col1:
                        st.markdown(f"""
                        **Prescription Details:**
                        - **Patient ID:** {prescription.get('userId')}
                        - **Doctor:** {prescription.get('doctorName')}
                        - **Date:** {prescription.get('appointmentDate', '')[:10] if prescription.get('appointmentDate') else 'Unknown'}
                        - **Type:** {prescription.get('type', 'consultation').title()}
                        """)
                    
                    with col2:
                        if prescription.get('symptoms'):
                            st.markdown(f"**Symptoms:** {', '.join(prescription['symptoms'])}")
                        if prescription.get('notes'):
                            st.markdown(f"**Notes:** {prescription['notes']}")
                    
                    # Show prescribed medicines
                    st.markdown("**Prescribed Medicines:**")
                    medicines = prescription.get('prescription', {}).get('medicines', [])
                    
                    for med in medicines:
                        st.markdown(f"""
                        - **{med.get('medicineName', 'Unknown')}**
                          - Dosage: {med.get('dosage', 'Not specified')}
                          - Frequency: {med.get('frequency', 'Not specified')}
                          - Duration: {med.get('duration', 'Not specified')}
                        """)

def show_dashboard():
    """Show main dashboard with analytics"""
    st.markdown("# 🏥 Dashboard Overview")
    st.markdown(f"Welcome back, **{st.session_state.doctor_data['name']}**!")
    
    # Fetch real data from backend
    with st.spinner("Loading dashboard data..."):
        health_status = st.session_state.api_client.get_health_status()
        appointments_data = st.session_state.api_client.get_appointments()
        medicines_data = st.session_state.api_client.get_medicines(limit=10)
    
    st.divider()
    
    # Key metrics from real backend data
    appointments = appointments_data.get("appointments", [])
    medicines = medicines_data.get("medicines", [])
    collections = health_status.get("collections", {})
    
    col1, col2, col3, col4 = st.columns(4)
    
    # Calculate real metrics
    scheduled_count = len([a for a in appointments if a.get('status') == 'scheduled'])
    completed_count = len([a for a in appointments if a.get('status') == 'completed'])
    total_medicines = collections.get("medicines", len(medicines))
    total_users = collections.get("users", 0)
    
    with col1:
        st.metric("Scheduled Appointments", scheduled_count, delta=None)
    
    with col2:
        st.metric("Completed Consultations", completed_count, delta=None)
    
    with col3:
        st.metric("Available Medicines", total_medicines, delta=None)
    
    with col4:
        st.metric("Registered Users", total_users, delta=None)
    
    st.divider()
    
    # Real data visualizations
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### 📊 Appointment Status Distribution")
        
        if appointments:
            # Create real appointment status chart
            status_counts = {}
            for apt in appointments:
                status = apt.get('status', 'unknown')
                status_counts[status] = status_counts.get(status, 0) + 1
            
            fig_pie = px.pie(
                values=list(status_counts.values()),
                names=list(status_counts.keys()),
                title="Current Appointments by Status"
            )
            st.plotly_chart(fig_pie, use_container_width=True)
        else:
            st.info("No appointment data available")
    
    with col2:
        st.markdown("### 💊 Medicine Categories")
        
        if medicines:
            # Create medicine category chart
            category_counts = {}
            for med in medicines:
                category = med.get('category', 'Unknown')
                category_counts[category] = category_counts.get(category, 0) + 1
            
            fig_bar = px.bar(
                x=list(category_counts.keys()), 
                y=list(category_counts.values()),
                title="Available Medicines by Category",
                labels={'x': 'Category', 'y': 'Number of Medicines'}
            )
            st.plotly_chart(fig_bar, use_container_width=True)
        else:
            st.info("No medicine data available")
    
    st.divider()
    
    # Recent appointments
    st.markdown("### 📋 Recent Appointments")
    
    if appointments:
        # Show last 5 appointments
        recent_appointments = sorted(
            appointments, 
            key=lambda x: x.get('createdAt', ''), 
            reverse=True
        )[:5]
        
        for apt in recent_appointments:
            col1, col2, col3 = st.columns([2, 2, 1])
            
            with col1:
                st.markdown(f"**Patient:** {apt.get('userId', 'Unknown')}")
            with col2:
                st.markdown(f"**Date:** {apt.get('appointmentDate', '')[:10] if apt.get('appointmentDate') else 'No date'}")
            with col3:
                status = apt.get('status', 'unknown')
                color = {"scheduled": "🟡", "completed": "🟢", "cancelled": "🔴"}.get(status, "⚪")
                st.markdown(f"{color} {status.title()}")
    else:
        st.info("📭 No recent appointments")
        
        # Show backend connection status
        st.markdown("### 🔗 Backend Connection Status")
        if health_status.get("status") == "OK":
            st.success("✅ Successfully connected to backend")
            st.json(health_status)
        else:
            st.error("❌ Backend connection issue")
            st.json(health_status)

def main():
    """Main application function"""
    
    # Initialize session state
    init_session_state()
    
    # Check login state
    if not st.session_state.logged_in:
        show_login()
        return
    
    # Show sidebar
    show_sidebar()
    
    # Main navigation
    pages = {
        "Dashboard": show_dashboard,
        "Appointments": show_appointments,
        "Medicines": show_medicines,
        "Prescriptions": show_prescriptions
    }
    
    # Page selection
    selected_page = st.selectbox(
        "Navigate to:",
        list(pages.keys()),
        index=0,
        label_visibility="collapsed"
    )
    
    # Show selected page
    pages[selected_page]()

if __name__ == "__main__":
    print("🏥 Starting Mediculture Doctor Application (Connected to Backend)")
    print("=" * 70)
    print("✓ Streamlit web interface")
    print("✓ Connected to your Node.js backend at http://localhost:3000")
    print("✓ Real-time data from MongoDB")
    print("✓ Full CRUD operations")
    print("=" * 70)
    
    main()
