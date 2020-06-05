//
//  ContentView.swift
//  iExpense
//
//  Created by Dathan Wong on 6/3/20.
//  Copyright © 2020 Dathan Wong. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView{
            List{
                ForEach(expenses.items) { item in
                    HStack{
                        ExpenseView(item: item, expenses: self.expenses)
                    }
                }
            .onDelete(perform: removeItems)
            }
            .navigationBarTitle("iExpense")
            .navigationBarItems(trailing:
                Button(action:{
                    self.showingAddExpense = true
                }){
                    Image(systemName: "plus")
                }
            ).sheet(isPresented: $showingAddExpense) {
                AddView(expenses: self.expenses)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
}

struct ExpenseItem: Identifiable, Codable{
    let id = UUID()
    let name: String
    let type: String
    let amount: Int
}

class Expenses: ObservableObject{
    @Published var items = [ExpenseItem](){
        didSet{
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items){
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init(){
        if let items = UserDefaults.standard.data(forKey: "Items"){
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items){
                self.items = decoded
                return
            }
        }
        self.items = []
    }
    
    func find(_ item: ExpenseItem) -> Int?{
        for i in 0..<items.count{
            if(item.id == items[i].id){
                return i
            }
        }
        return nil
    }
}

struct ExpenseView: View{
    @State var item: ExpenseItem
    @State var expenses: Expenses
    
    var body: some View{
        HStack{
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.type)
            }
            Spacer()
            if(item.amount < 10){
                Text("$\(item.amount)").modifier(Under10())
            }else if(item.amount < 100){
                Text("$\(item.amount)").modifier(Under100())
            }else{
                Text("$\(item.amount)").modifier(Over100())
            }
            Button(action: {
                if let index = self.expenses.find(self.item){
                    self.expenses.items.remove(at: index)
                }
            }) {
                Text("Done")
                    .foregroundColor(.red)
            }
        }
    }
}

struct Under10: ViewModifier{
    func body(content: Content) -> some View {
        content.foregroundColor(.yellow)
    }
}

struct Under100: ViewModifier{
    func body(content: Content) -> some View {
        content.foregroundColor(.black)
    }
}

struct Over100: ViewModifier{
    func body(content: Content) -> some View {
        content.foregroundColor(.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
