import SwiftUI

struct RecurringPaymentRowView: View {
    let payment: RecurringPayment
    @ObservedObject var viewModel: RecurringPaymentsViewModel

    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")
    let overdueColor = Color.orange

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: payment.iconName)
                .font(.system(size: 20))
                .foregroundColor(payment.accentColor)
                .frame(width: 44, height: 44)
                .background(payment.accentColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(payment.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(mainTextColor)
                    .strikethrough(payment.isEnded, color: secondaryTextColor)

                Text(String(format: "$%.2f / %@", payment.amount, payment.recurrenceInterval.rawValue))
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
                    .strikethrough(payment.isEnded, color: secondaryTextColor)

                HStack(spacing: 4) {
                    Text(payment.isEnded ? "Ended:" : (payment.isPastDue ? "Due:" : "Next:"))
                        .font(.caption.weight(.medium))
                        .foregroundColor(payment.isEnded ? secondaryTextColor : (payment.isPastDue ? overdueColor : payment.accentColor))
                    Text("\(payment.nextDueDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(payment.isEnded ? secondaryTextColor : (payment.isPastDue ? overdueColor : mainTextColor))
                }
                if payment.isEnded, let endDate = payment.endDate {
                     Text("Concluded on \(endDate, style: .date)")
                        .font(.caption2)
                        .foregroundColor(secondaryTextColor)
                } else if let endDate = payment.endDate {
                    Text("Ends: \(endDate, style: .date)")
                        .font(.caption2)
                        .foregroundColor(secondaryTextColor)
                }
            }

            Spacer()

            if !payment.isEnded {
                Button {
                    viewModel.markAsPaidAndAdvanceDueDate(paymentId: payment.id)
                } label: {
                    Text("Paid")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .foregroundColor(Color.black)
                        .background(accentColorTeal)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            } else {
                 Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(payment.accentColor.opacity(0.7))
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .opacity(payment.isEnded ? 0.7 : 1.0)
    }
}

struct RecurringPaymentsListView: View {
    @StateObject private var viewModel = RecurringPaymentsViewModel()
    @State private var showingAddEditPaymentSheet = false
    @State private var paymentToEdit: RecurringPayment? = nil
    @State private var showPermissionDeniedAlert = false

    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let mainTextColor = Color.white
    let accentColorTeal = Color(hex: "3AD7D5")
    let secondaryTextColor = Color(hex: "A0A0A0")
    
    var body: some View {
        NavigationView {
            ZStack {
                screenBackgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    if viewModel.notificationAuthStatus == .denied || viewModel.notificationAuthStatus == .notDetermined {
                        NotificationPermissionBar(viewModel: viewModel, showPermissionDeniedAlert: $showPermissionDeniedAlert)
                            .padding(.horizontal)
                            .padding(.top, 5)
                    }
                    
                    if viewModel.recurringPayments.isEmpty {
                        emptyStateView
                    } else {
                        List {
                            ForEach(viewModel.recurringPayments) { payment in
                                RecurringPaymentRowView(payment: payment, viewModel: viewModel)
                                    .onTapGesture {
                                        self.paymentToEdit = payment
                                        self.showingAddEditPaymentSheet = true
                                    }
                                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(screenBackgroundColor)
                            }
                            .onDelete(perform: viewModel.deletePayment)
                        }
                        .listStyle(.plain)
                        .background(screenBackgroundColor)
                        .refreshable {
                            viewModel.scheduleInitialRemindersForAllActivePayments()
                        }
                    }
                }
            }
            .navigationTitle("Recurring & Bills")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.paymentToEdit = nil // For adding new
                        self.showingAddEditPaymentSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(accentColorTeal)
                    }
                }

            }
            .sheet(isPresented: $showingAddEditPaymentSheet) {
                AddEditRecurringPaymentView(viewModel: viewModel, paymentToEdit: paymentToEdit)
            }
            .alert("Notification Permission Required", isPresented: $showPermissionDeniedAlert) {
                Button("Open Settings") { viewModel.openAppSettings() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("To receive bill reminders, please enable notifications for Smart-Rupay in your iPhone's Settings app.")
            }
            .onAppear {

                 viewModel.checkNotificationPermission()
                 if viewModel.notificationAuthStatus == .authorized {
                     viewModel.scheduleInitialRemindersForAllActivePayments()
                 }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Spacer()
            Image(systemName: "repeat.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(secondaryTextColor.opacity(0.5))
            Text("No Recurring Payments")
                .font(.title2.weight(.semibold))
                .foregroundColor(secondaryTextColor)
            Text("Track your subscriptions and regular bills by adding them here. Tap '+' to start.")
                .font(.subheadline)
                .foregroundColor(secondaryTextColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                self.paymentToEdit = nil
                self.showingAddEditPaymentSheet = true
            } label: {
                Text("Add First Payment")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(accentColorTeal)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .padding(.top)
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct NotificationPermissionBar: View {
    @ObservedObject var viewModel: RecurringPaymentsViewModel
    @Binding var showPermissionDeniedAlert: Bool
    
    let cardBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let accentColorTeal = Color(hex: "3AD7D5")

    var body: some View {
        HStack {
            Image(systemName: "bell.badge.fill")
                .foregroundColor(accentColorTeal)
            VStack(alignment: .leading) {
                Text("Enable Bill Reminders")
                    .font(.footnote.bold())
                Text("Get notified before your bills are due.")
                    .font(.caption2)
            }
            Spacer()
            Button {
                if viewModel.notificationAuthStatus == .denied {
                    showPermissionDeniedAlert = true
                } else { // .notDetermined or other states
                    viewModel.requestNotificationPermission()
                }
            } label: {
                Text(viewModel.notificationAuthStatus == .denied ? "Settings" : "Enable")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(accentColorTeal.opacity(0.2))
                    .foregroundColor(accentColorTeal)
                    .cornerRadius(6)
            }
        }
        .padding(12)
        .background(cardBackgroundColor)
        .cornerRadius(10)
    }
}


// MARK: - Preview
struct RecurringPaymentsListView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringPaymentsListView()
    }
}
