// In the file containing RecurringPaymentsListView

import SwiftUI

struct RecurringPaymentsListView: View {
    // MARK: - Properties
    @StateObject private var viewModel = RecurringPaymentsViewModel()
    @State private var showingAddEditPaymentSheet = false
    @State private var paymentToEdit: RecurringPayment? = nil
    @State private var showPermissionDeniedAlert = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.App.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Header with improved spacing
                    Text("Recurring & Bills")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color.App.textPrimary)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    // A subtle divider for better visual separation
                    Divider()
                        .background(Color.App.card)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    // Main Content Area
                    if viewModel.recurringPayments.isEmpty {
                        emptyStateView
                    } else {
                        paymentsList
                    }
                }
                .padding(.top)
                
                // Floating Action Button for adding new payments
                floatingAddButton
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddEditPaymentSheet) {
                AddEditRecurringPaymentView(viewModel: viewModel, paymentToEdit: paymentToEdit)
            }
            .alert("Notification Permission Required", isPresented: $showPermissionDeniedAlert) {
                Button("Open Settings") { viewModel.openAppSettings() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("To receive bill reminders, please enable notifications in your iPhone's Settings app.")
            }
            .onAppear {
                viewModel.checkNotificationPermission()
            }
        }
    }
    
    // MARK: - Subviews
    private var paymentsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.notificationAuthStatus != .authorized {
                    NotificationPermissionBar(viewModel: viewModel, showPermissionDeniedAlert: $showPermissionDeniedAlert)
                        .padding([.horizontal, .bottom])
                }
                
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.recurringPayments) { payment in
                        RecurringPaymentRowView(payment: payment, viewModel: viewModel)
                            .onTapGesture {
                                self.paymentToEdit = payment
                                self.showingAddEditPaymentSheet = true
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
        }
    }
    
    private var floatingAddButton: some View {
        Button(action: {
            self.paymentToEdit = nil
            self.showingAddEditPaymentSheet = true
        }) {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .foregroundColor(.black)
                .frame(width: 60, height: 60)
                .background(Color.App.accent)
                .clipShape(Circle())
                .shadow(color: Color.App.accent.opacity(0.4), radius: 10, y: 5)
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "repeat.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.App.accent.opacity(0.6))
            Text("No Recurring Payments")
                .font(.title2.weight(.bold))
            Text("Track subscriptions and bills so you never miss a due date. Tap '+' to start.")
                .font(.subheadline)
                .foregroundColor(.App.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Refined Row View
struct RecurringPaymentRowView: View {
    let payment: RecurringPayment
    @ObservedObject var viewModel: RecurringPaymentsViewModel

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: payment.iconName)
                .font(.title3.weight(.medium))
                .foregroundColor(payment.accentColor)
                .frame(width: 50, height: 50)
                .background(payment.accentColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(payment.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.App.textPrimary)
                    .strikethrough(payment.isEnded, color: Color.App.textSecondary)

                HStack(spacing: 4) {
                    let isOverdue = payment.isPastDue && !payment.isEnded
                    
                    Text(payment.isEnded ? "Ended" : (isOverdue ? "Due" : "Next"))
                        .font(.caption.weight(.semibold))
                        // Using a brighter orange for better contrast when overdue
                        .foregroundColor(isOverdue ? Color.App.accentOrange : Color.App.textSecondary)
                    
                    Text(payment.nextDueDate, style: .date)
                        .font(.caption.weight(.semibold))
                        // Bolder text color for overdue date
                        .foregroundColor(isOverdue ? .white : Color.App.textSecondary)
                }
            }

            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text("₹\(Int(payment.amount))")
                    .font(.headline.bold())
                    .strikethrough(payment.isEnded, color: Color.App.textSecondary)
                
                Text(payment.recurrenceInterval.rawValue)
                    .font(.caption)
                    .foregroundColor(Color.App.textSecondary)
            }

            if !payment.isEnded {
                // Redesigned "Mark Paid" button for better visibility and feel
                Button {
                    viewModel.markAsPaidAndAdvanceDueDate(paymentId: payment.id)
                } label: {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.bold))
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.App.accent.gradient) // Using a gradient
                        .clipShape(Circle())
                        .shadow(color: Color.App.accent.opacity(0.3), radius: 5, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.App.card)
        .cornerRadius(20)
        .overlay(
             // Adding a colored border for overdue items to make them stand out more
            RoundedRectangle(cornerRadius: 20)
                .stroke(payment.isPastDue && !payment.isEnded ? Color.App.accentOrange : Color.clear, lineWidth: 1.5)
        )
        .opacity(payment.isEnded ? 0.6 : 1.0)
    }
}

// MARK: - Redesigned Notification Bar
struct NotificationPermissionBar: View {
    @ObservedObject var viewModel: RecurringPaymentsViewModel
    @Binding var showPermissionDeniedAlert: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "bell.badge.fill")
                .font(.title2)
                .foregroundColor(Color.App.accent)
            
            VStack(alignment: .leading) {
                Text("Enable Bill Reminders")
                    .font(.headline)
                    .foregroundColor(Color.App.textPrimary)
                Text("Get notified before payments are due.")
                    .font(.caption)
                    .foregroundColor(Color.App.textSecondary)
            }
            
            Spacer()
            
            Button(action: {
                if viewModel.notificationAuthStatus == .denied {
                    showPermissionDeniedAlert = true
                } else {
                    viewModel.requestNotificationPermission()
                }
            }) {
                Text(viewModel.notificationAuthStatus == .denied ? "Settings" : "Enable")
                    .font(.callout.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.App.accent.opacity(0.2))
                    .foregroundColor(Color.App.accent)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.App.card)
        .cornerRadius(20)
    }
}

// MARK: - Preview
struct RecurringPaymentsListView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringPaymentsListView()
    }
}
